-- ============================================================
-- RENTAL MOBIL - QUERY PENTING
-- Database: MySQL 8+
-- ============================================================

-- ============================================================
-- D) QUERY PENTING
-- ============================================================

-- ============================================================
-- 1️⃣ QUERY KENDARAAN AVAILABLE
-- Mencari kendaraan yang tersedia dalam rentang waktu tertentu
-- ============================================================

-- Parameter yang perlu diganti:
-- @branch_id    : ID cabang
-- @request_start: Waktu mulai sewa (DATETIME)
-- @request_end  : Waktu selesai sewa (DATETIME)
-- @vehicle_type : Tipe kendaraan (opsional)
-- @min_capacity : Kapasitas minimum (opsional)

-- Query dasar: Kendaraan available di rentang waktu tertentu
DELIMITER //

DROP PROCEDURE IF EXISTS `sp_get_available_vehicles`//

CREATE PROCEDURE `sp_get_available_vehicles`(
  IN p_branch_id INT,
  IN p_request_start DATETIME,
  IN p_request_end DATETIME,
  IN p_vehicle_type VARCHAR(20),
  IN p_min_capacity INT
)
BEGIN
  SELECT 
    v.id,
    v.license_plate,
    v.name,
    v.brand,
    v.model,
    v.year,
    v.color,
    v.type,
    v.transmission,
    v.fuel_type,
    v.capacity,
    v.luggage_capacity,
    v.price_per_day,
    v.image_url,
    v.is_featured,
    -- Hitung rating rata-rata
    COALESCE(
      (SELECT ROUND(AVG(r.rating), 1) 
       FROM reviews r 
       WHERE r.vehicle_id = v.id AND r.is_published = 1), 
      0
    ) AS avg_rating,
    -- Hitung jumlah review
    (SELECT COUNT(*) 
     FROM reviews r 
     WHERE r.vehicle_id = v.id AND r.is_published = 1
    ) AS review_count
  FROM vehicles v
  WHERE v.branch_id = p_branch_id
    AND v.is_active = 1
    -- Filter tipe kendaraan (opsional)
    AND (p_vehicle_type IS NULL OR v.type = p_vehicle_type)
    -- Filter kapasitas minimum (opsional)
    AND (p_min_capacity IS NULL OR v.capacity >= p_min_capacity)
    -- OVERLAP RULE: Tidak ada blok aktif yang overlap dengan request
    AND NOT EXISTS (
      SELECT 1 
      FROM vehicle_blocks vb
      WHERE vb.vehicle_id = v.id
        AND vb.status = 'active'
        -- Overlap condition: block_start < request_end AND block_end > request_start
        AND vb.block_start < p_request_end
        AND vb.block_end > p_request_start
    )
  ORDER BY v.is_featured DESC, v.price_per_day ASC;
END//

DELIMITER ;

-- Contoh penggunaan:
-- CALL sp_get_available_vehicles(1, '2026-02-15 08:00:00', '2026-02-15 21:59:00', NULL, NULL);
-- CALL sp_get_available_vehicles(1, '2026-02-15 08:00:00', '2026-02-15 21:59:00', 'MPV', 7);


-- ============================================================
-- Query alternatif tanpa stored procedure
-- ============================================================

-- SET @branch_id = 1;
-- SET @request_start = '2026-02-15 08:00:00';
-- SET @request_end = '2026-02-15 21:59:00';

-- SELECT v.*
-- FROM vehicles v
-- WHERE v.branch_id = @branch_id
--   AND v.is_active = 1
--   AND v.id NOT IN (
--     SELECT DISTINCT vb.vehicle_id
--     FROM vehicle_blocks vb
--     WHERE vb.status = 'active'
--       AND vb.block_start < @request_end
--       AND vb.block_end > @request_start
--   );


-- ============================================================
-- 2️⃣ QUERY DASHBOARD STATUS KENDARAAN REALTIME
-- Menghitung status semua kendaraan saat ini
-- ============================================================

-- View untuk dashboard status kendaraan
DROP VIEW IF EXISTS `vw_vehicle_realtime_status`;

CREATE VIEW `vw_vehicle_realtime_status` AS
SELECT 
  v.id AS vehicle_id,
  v.branch_id,
  v.license_plate,
  v.name,
  v.type,
  v.price_per_day,
  v.is_active,
  -- Hitung status berdasarkan vehicle_blocks
  CASE
    -- Jika ada maintenance aktif sekarang
    WHEN EXISTS (
      SELECT 1 FROM vehicle_blocks vb 
      WHERE vb.vehicle_id = v.id 
        AND vb.block_type = 'maintenance'
        AND vb.status = 'active'
        AND NOW() BETWEEN vb.block_start AND vb.block_end
    ) THEN 'maintenance'
    -- Jika ada booking yang sedang berjalan (in_use)
    WHEN EXISTS (
      SELECT 1 FROM vehicle_blocks vb 
      INNER JOIN bookings b ON vb.reference_id = b.id AND vb.block_type = 'booking'
      WHERE vb.vehicle_id = v.id 
        AND vb.status = 'active'
        AND b.status = 'in_progress'
        AND NOW() BETWEEN vb.block_start AND vb.block_end
    ) THEN 'in_use'
    -- Jika ada booking confirmed yang akan datang atau sedang berlangsung
    WHEN EXISTS (
      SELECT 1 FROM vehicle_blocks vb 
      INNER JOIN bookings b ON vb.reference_id = b.id AND vb.block_type = 'booking'
      WHERE vb.vehicle_id = v.id 
        AND vb.status = 'active'
        AND b.status IN ('confirmed', 'in_progress')
        AND NOW() BETWEEN vb.block_start AND vb.block_end
    ) THEN 'booked'
    -- Jika tidak aktif
    WHEN v.is_active = 0 THEN 'inactive'
    -- Default: available
    ELSE 'available'
  END AS current_status,
  -- Info booking aktif (jika ada)
  (
    SELECT b.booking_code 
    FROM vehicle_blocks vb 
    INNER JOIN bookings b ON vb.reference_id = b.id AND vb.block_type = 'booking'
    WHERE vb.vehicle_id = v.id 
      AND vb.status = 'active'
      AND b.status IN ('confirmed', 'in_progress')
      AND NOW() BETWEEN vb.block_start AND vb.block_end
    LIMIT 1
  ) AS current_booking_code,
  -- Waktu block berakhir (jika ada)
  (
    SELECT vb.block_end 
    FROM vehicle_blocks vb 
    WHERE vb.vehicle_id = v.id 
      AND vb.status = 'active'
      AND NOW() BETWEEN vb.block_start AND vb.block_end
    ORDER BY vb.block_end DESC
    LIMIT 1
  ) AS block_ends_at
FROM vehicles v;

-- Query dashboard summary
SELECT 
  b.id AS branch_id,
  b.name AS branch_name,
  COUNT(CASE WHEN vs.current_status = 'available' THEN 1 END) AS available_count,
  COUNT(CASE WHEN vs.current_status = 'booked' THEN 1 END) AS booked_count,
  COUNT(CASE WHEN vs.current_status = 'in_use' THEN 1 END) AS in_use_count,
  COUNT(CASE WHEN vs.current_status = 'maintenance' THEN 1 END) AS maintenance_count,
  COUNT(CASE WHEN vs.current_status = 'inactive' THEN 1 END) AS inactive_count,
  COUNT(*) AS total_vehicles
FROM branches b
LEFT JOIN vw_vehicle_realtime_status vs ON b.id = vs.branch_id
GROUP BY b.id, b.name;


-- ============================================================
-- 3️⃣ QUERY BOOKING LIST PER STATUS
-- Daftar booking berdasarkan status tertentu
-- ============================================================

-- View untuk daftar booking lengkap
DROP VIEW IF EXISTS `vw_booking_list`;

CREATE VIEW `vw_booking_list` AS
SELECT 
  b.id,
  b.booking_code,
  b.branch_id,
  br.name AS branch_name,
  b.customer_id,
  c.full_name AS customer_name,
  c.phone AS customer_phone,
  c.email AS customer_email,
  b.booking_date,
  b.start_datetime,
  b.end_datetime,
  b.total_days,
  b.subtotal,
  b.discount_amount,
  b.tax_amount,
  b.total_amount,
  b.deposit_amount,
  b.status,
  b.payment_status,
  b.expires_at,
  b.confirmed_at,
  b.cancelled_at,
  b.notes,
  b.created_at,
  -- Hitung sisa waktu expired (untuk pending)
  CASE 
    WHEN b.status = 'pending' AND b.expires_at > NOW() 
    THEN TIMESTAMPDIFF(MINUTE, NOW(), b.expires_at)
    ELSE NULL
  END AS minutes_until_expired,
  -- Daftar kendaraan (JSON)
  (
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'vehicle_id', bi.vehicle_id,
        'vehicle_name', v.name,
        'license_plate', v.license_plate,
        'price_per_day', bi.price_per_day,
        'subtotal', bi.subtotal
      )
    )
    FROM booking_items bi
    INNER JOIN vehicles v ON bi.vehicle_id = v.id
    WHERE bi.booking_id = b.id
  ) AS vehicles
FROM bookings b
INNER JOIN branches br ON b.branch_id = br.id
INNER JOIN customers c ON b.customer_id = c.id;

-- Query booking per status
-- Parameter: @status = 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'expired'

-- Contoh: Ambil semua booking pending yang akan expired dalam 30 menit
SELECT * FROM vw_booking_list 
WHERE status = 'pending' 
  AND minutes_until_expired <= 30
ORDER BY expires_at ASC;

-- Contoh: Ambil booking confirmed hari ini
SELECT * FROM vw_booking_list 
WHERE status = 'confirmed' 
  AND DATE(start_datetime) = CURDATE()
ORDER BY start_datetime ASC;

-- Contoh: Ambil booking in_progress yang harus kembali hari ini
SELECT * FROM vw_booking_list 
WHERE status = 'in_progress' 
  AND DATE(end_datetime) = CURDATE()
ORDER BY end_datetime ASC;


-- ============================================================
-- QUERY TAMBAHAN YANG BERGUNA
-- ============================================================

-- 4️⃣ Query pembayaran pending yang akan expired
SELECT 
  p.*,
  b.booking_code,
  c.full_name AS customer_name,
  c.phone AS customer_phone
FROM payments p
INNER JOIN bookings b ON p.booking_id = b.id
INNER JOIN customers c ON b.customer_id = c.id
WHERE p.status = 'pending'
  AND p.expired_at IS NOT NULL
  AND p.expired_at <= DATE_ADD(NOW(), INTERVAL 1 HOUR)
ORDER BY p.expired_at ASC;

-- 5️⃣ Query revenue report per periode
SELECT 
  DATE_FORMAT(p.paid_at, '%Y-%m') AS period,
  COUNT(DISTINCT b.id) AS total_bookings,
  COUNT(DISTINCT b.customer_id) AS unique_customers,
  SUM(p.amount) AS total_revenue,
  AVG(p.amount) AS avg_payment
FROM payments p
INNER JOIN bookings b ON p.booking_id = b.id
WHERE p.status = 'success'
  AND p.paid_at BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m')
ORDER BY period;

-- 6️⃣ Query kendaraan paling populer
SELECT 
  v.id,
  v.name,
  v.type,
  v.price_per_day,
  COUNT(bi.id) AS total_bookings,
  SUM(bi.subtotal) AS total_revenue,
  COALESCE(AVG(r.rating), 0) AS avg_rating
FROM vehicles v
LEFT JOIN booking_items bi ON v.id = bi.vehicle_id
LEFT JOIN bookings b ON bi.booking_id = b.id AND b.status IN ('confirmed', 'in_progress', 'completed')
LEFT JOIN reviews r ON v.id = r.vehicle_id AND r.is_published = 1
GROUP BY v.id, v.name, v.type, v.price_per_day
ORDER BY total_bookings DESC, total_revenue DESC
LIMIT 10;

-- 7️⃣ Query jadwal maintenance mendatang
SELECT 
  m.*,
  v.name AS vehicle_name,
  v.license_plate
FROM maintenance_records m
INNER JOIN vehicles v ON m.vehicle_id = v.id
WHERE m.status IN ('scheduled', 'in_progress')
  AND m.scheduled_start >= NOW()
ORDER BY m.scheduled_start ASC;
