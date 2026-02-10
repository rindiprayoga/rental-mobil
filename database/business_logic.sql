-- ============================================================
-- RENTAL MOBIL - BUSINESS LOGIC & STORED PROCEDURES
-- Database: MySQL 8+
-- ============================================================

-- ============================================================
-- E) BUSINESS LOGIC RULES
-- ============================================================

-- ============================================================
-- 1. VALIDASI BOOKING START DALAM JAM OPERASIONAL
-- ============================================================

DELIMITER //

DROP FUNCTION IF EXISTS `fn_is_within_business_hours`//

CREATE FUNCTION `fn_is_within_business_hours`(
  p_branch_id INT,
  p_datetime DATETIME
) RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_day_of_week TINYINT;
  DECLARE v_time TIME;
  DECLARE v_is_valid TINYINT(1) DEFAULT 0;
  
  SET v_day_of_week = DAYOFWEEK(p_datetime) - 1; -- 0=Minggu, 1=Senin, dst
  SET v_time = TIME(p_datetime);
  
  SELECT 
    CASE 
      WHEN is_closed = 1 THEN 0
      WHEN v_time >= open_time AND v_time <= close_time THEN 1
      ELSE 0
    END INTO v_is_valid
  FROM business_hours
  WHERE branch_id = p_branch_id
    AND day_of_week = v_day_of_week;
  
  RETURN COALESCE(v_is_valid, 0);
END//

DELIMITER ;


-- ============================================================
-- 2. FUNGSI HITUNG END_DATETIME OTOMATIS (CUTOFF)
-- ============================================================

DELIMITER //

DROP FUNCTION IF EXISTS `fn_calculate_end_datetime`//

CREATE FUNCTION `fn_calculate_end_datetime`(
  p_branch_id INT,
  p_start_datetime DATETIME,
  p_total_days INT
) RETURNS DATETIME
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_end_date DATE;
  DECLARE v_cutoff_time TIME;
  DECLARE v_day_of_week TINYINT;
  
  -- Hitung tanggal akhir
  SET v_end_date = DATE_ADD(DATE(p_start_datetime), INTERVAL (p_total_days - 1) DAY);
  SET v_day_of_week = DAYOFWEEK(v_end_date) - 1;
  
  -- Ambil cutoff time untuk hari tersebut
  SELECT cutoff_time INTO v_cutoff_time
  FROM business_hours
  WHERE branch_id = p_branch_id
    AND day_of_week = v_day_of_week;
  
  -- Default cutoff jika tidak ada
  IF v_cutoff_time IS NULL THEN
    SET v_cutoff_time = '21:59:00';
  END IF;
  
  RETURN CONCAT(v_end_date, ' ', v_cutoff_time);
END//

DELIMITER ;


-- ============================================================
-- 3. PROCEDURE: CREATE BOOKING
-- Membuat booking baru dengan validasi lengkap
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_create_booking`//

CREATE PROCEDURE `sp_create_booking`(
  IN p_branch_id INT,
  IN p_customer_id INT,
  IN p_vehicle_ids JSON,
  IN p_start_datetime DATETIME,
  IN p_total_days INT,
  IN p_notes TEXT,
  OUT p_booking_id INT,
  OUT p_booking_code VARCHAR(20),
  OUT p_error_message VARCHAR(255)
)
BEGIN
  DECLARE v_end_datetime DATETIME;
  DECLARE v_expires_at DATETIME;
  DECLARE v_subtotal DECIMAL(14,2) DEFAULT 0;
  DECLARE v_tax_rate DECIMAL(5,4) DEFAULT 0.11; -- PPN 11%
  DECLARE v_tax_amount DECIMAL(14,2);
  DECLARE v_total_amount DECIMAL(14,2);
  DECLARE v_vehicle_id INT;
  DECLARE v_price_per_day DECIMAL(12,2);
  DECLARE v_item_subtotal DECIMAL(14,2);
  DECLARE v_is_available TINYINT(1);
  DECLARE v_counter INT DEFAULT 0;
  DECLARE v_vehicle_count INT;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_error_message = 'Terjadi kesalahan sistem. Silakan coba lagi.';
    SET p_booking_id = NULL;
    SET p_booking_code = NULL;
  END;
  
  -- Inisialisasi
  SET p_error_message = NULL;
  SET p_booking_id = NULL;
  SET p_booking_code = NULL;
  
  -- Validasi 1: Cek jam operasional
  IF fn_is_within_business_hours(p_branch_id, p_start_datetime) = 0 THEN
    SET p_error_message = 'Waktu booking di luar jam operasional cabang.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid business hours';
  END IF;
  
  -- Hitung end_datetime otomatis berdasarkan cutoff
  SET v_end_datetime = fn_calculate_end_datetime(p_branch_id, p_start_datetime, p_total_days);
  
  -- Validasi 2: Start datetime harus di masa depan
  IF p_start_datetime <= NOW() THEN
    SET p_error_message = 'Waktu mulai sewa harus di masa depan.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid start datetime';
  END IF;
  
  -- Hitung jumlah kendaraan
  SET v_vehicle_count = JSON_LENGTH(p_vehicle_ids);
  
  IF v_vehicle_count = 0 THEN
    SET p_error_message = 'Minimal pilih 1 kendaraan.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No vehicles selected';
  END IF;
  
  START TRANSACTION;
  
  -- Validasi 3: Cek availability setiap kendaraan
  WHILE v_counter < v_vehicle_count DO
    SET v_vehicle_id = JSON_EXTRACT(p_vehicle_ids, CONCAT('$[', v_counter, ']'));
    
    -- Cek apakah kendaraan tersedia
    SELECT COUNT(*) = 0 INTO v_is_available
    FROM vehicle_blocks vb
    WHERE vb.vehicle_id = v_vehicle_id
      AND vb.status = 'active'
      AND vb.block_start < v_end_datetime
      AND vb.block_end > p_start_datetime;
    
    IF v_is_available = 0 THEN
      SET p_error_message = CONCAT('Kendaraan dengan ID ', v_vehicle_id, ' tidak tersedia di waktu tersebut.');
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle not available';
    END IF;
    
    SET v_counter = v_counter + 1;
  END WHILE;
  
  -- Generate booking code
  SET p_booking_code = CONCAT('BK', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 10000), 4, '0'));
  
  -- Set expires_at (15 menit dari sekarang)
  SET v_expires_at = DATE_ADD(NOW(), INTERVAL 15 MINUTE);
  
  -- Insert booking header (subtotal dihitung setelah items)
  INSERT INTO bookings (
    booking_code, branch_id, customer_id, booking_date,
    start_datetime, end_datetime, total_days,
    status, payment_status, expires_at, notes
  ) VALUES (
    p_booking_code, p_branch_id, p_customer_id, CURDATE(),
    p_start_datetime, v_end_datetime, p_total_days,
    'pending', 'unpaid', v_expires_at, p_notes
  );
  
  SET p_booking_id = LAST_INSERT_ID();
  
  -- Reset counter dan insert booking items + vehicle blocks
  SET v_counter = 0;
  
  WHILE v_counter < v_vehicle_count DO
    SET v_vehicle_id = JSON_EXTRACT(p_vehicle_ids, CONCAT('$[', v_counter, ']'));
    
    -- Ambil harga kendaraan
    SELECT price_per_day INTO v_price_per_day
    FROM vehicles
    WHERE id = v_vehicle_id;
    
    SET v_item_subtotal = v_price_per_day * p_total_days;
    SET v_subtotal = v_subtotal + v_item_subtotal;
    
    -- Insert booking item
    INSERT INTO booking_items (booking_id, vehicle_id, price_per_day, total_days, subtotal)
    VALUES (p_booking_id, v_vehicle_id, v_price_per_day, p_total_days, v_item_subtotal);
    
    -- Create vehicle block
    INSERT INTO vehicle_blocks (vehicle_id, block_type, reference_id, block_start, block_end, status, reason)
    VALUES (v_vehicle_id, 'booking', p_booking_id, p_start_datetime, v_end_datetime, 'active', 'Booking pending');
    
    SET v_counter = v_counter + 1;
  END WHILE;
  
  -- Hitung tax dan total
  SET v_tax_amount = v_subtotal * v_tax_rate;
  SET v_total_amount = v_subtotal + v_tax_amount;
  
  -- Update booking dengan total
  UPDATE bookings
  SET subtotal = v_subtotal,
      tax_amount = v_tax_amount,
      total_amount = v_total_amount
  WHERE id = p_booking_id;
  
  COMMIT;
  
END//

DELIMITER ;


-- ============================================================
-- 4. PROCEDURE: CONFIRM BOOKING (Setelah Pembayaran)
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_confirm_booking`//

CREATE PROCEDURE `sp_confirm_booking`(
  IN p_booking_id INT,
  IN p_payment_method VARCHAR(20),
  IN p_transaction_id VARCHAR(100),
  OUT p_success TINYINT(1),
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_status VARCHAR(20);
  DECLARE v_total_amount DECIMAL(14,2);
  DECLARE v_payment_code VARCHAR(30);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = 0;
    SET p_message = 'Terjadi kesalahan sistem.';
  END;
  
  -- Cek status booking
  SELECT status, total_amount INTO v_status, v_total_amount
  FROM bookings
  WHERE id = p_booking_id;
  
  IF v_status IS NULL THEN
    SET p_success = 0;
    SET p_message = 'Booking tidak ditemukan.';
  ELSEIF v_status != 'pending' THEN
    SET p_success = 0;
    SET p_message = CONCAT('Booking tidak dapat dikonfirmasi. Status saat ini: ', v_status);
  ELSE
    START TRANSACTION;
    
    -- Generate payment code
    SET v_payment_code = CONCAT('PAY', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), LPAD(FLOOR(RAND() * 1000), 3, '0'));
    
    -- Insert payment record
    INSERT INTO payments (payment_code, booking_id, amount, payment_method, transaction_id, status, paid_at)
    VALUES (v_payment_code, p_booking_id, v_total_amount, p_payment_method, p_transaction_id, 'success', NOW());
    
    -- Update booking status
    UPDATE bookings
    SET status = 'confirmed',
        payment_status = 'paid',
        confirmed_at = NOW(),
        expires_at = NULL
    WHERE id = p_booking_id;
    
    -- Update vehicle block reason
    UPDATE vehicle_blocks
    SET reason = 'Booking confirmed'
    WHERE block_type = 'booking'
      AND reference_id = p_booking_id;
    
    COMMIT;
    
    SET p_success = 1;
    SET p_message = 'Booking berhasil dikonfirmasi.';
  END IF;
  
END//

DELIMITER ;


-- ============================================================
-- 5. PROCEDURE: EXPIRE PENDING BOOKINGS
-- Dijalankan oleh scheduler/cron job
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_expire_pending_bookings`//

CREATE PROCEDURE `sp_expire_pending_bookings`()
BEGIN
  DECLARE v_expired_count INT DEFAULT 0;
  
  START TRANSACTION;
  
  -- Update booking status ke expired
  UPDATE bookings
  SET status = 'expired',
      cancelled_at = NOW(),
      cancellation_reason = 'Pembayaran tidak diterima dalam batas waktu.'
  WHERE status = 'pending'
    AND expires_at IS NOT NULL
    AND expires_at <= NOW();
  
  SET v_expired_count = ROW_COUNT();
  
  -- Cancel vehicle blocks untuk booking yang expired
  UPDATE vehicle_blocks vb
  INNER JOIN bookings b ON vb.reference_id = b.id AND vb.block_type = 'booking'
  SET vb.status = 'cancelled',
      vb.reason = 'Booking expired'
  WHERE b.status = 'expired'
    AND vb.status = 'active';
  
  COMMIT;
  
  SELECT v_expired_count AS expired_bookings;
  
END//

DELIMITER ;


-- ============================================================
-- 6. PROCEDURE: CANCEL BOOKING
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_cancel_booking`//

CREATE PROCEDURE `sp_cancel_booking`(
  IN p_booking_id INT,
  IN p_reason TEXT,
  IN p_cancelled_by VARCHAR(50),
  OUT p_success TINYINT(1),
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_status VARCHAR(20);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = 0;
    SET p_message = 'Terjadi kesalahan sistem.';
  END;
  
  SELECT status INTO v_status
  FROM bookings
  WHERE id = p_booking_id;
  
  IF v_status IS NULL THEN
    SET p_success = 0;
    SET p_message = 'Booking tidak ditemukan.';
  ELSEIF v_status IN ('completed', 'cancelled', 'expired') THEN
    SET p_success = 0;
    SET p_message = CONCAT('Booking tidak dapat dibatalkan. Status: ', v_status);
  ELSE
    START TRANSACTION;
    
    -- Update booking
    UPDATE bookings
    SET status = 'cancelled',
        cancelled_at = NOW(),
        cancellation_reason = CONCAT('[', p_cancelled_by, '] ', COALESCE(p_reason, 'Tidak ada alasan')),
        expires_at = NULL
    WHERE id = p_booking_id;
    
    -- Cancel vehicle blocks
    UPDATE vehicle_blocks
    SET status = 'cancelled',
        reason = CONCAT('Booking dibatalkan: ', COALESCE(p_reason, '-'))
    WHERE block_type = 'booking'
      AND reference_id = p_booking_id
      AND status = 'active';
    
    COMMIT;
    
    SET p_success = 1;
    SET p_message = 'Booking berhasil dibatalkan.';
  END IF;
  
END//

DELIMITER ;


-- ============================================================
-- 7. PROCEDURE: CREATE MAINTENANCE BLOCK
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_create_maintenance`//

CREATE PROCEDURE `sp_create_maintenance`(
  IN p_vehicle_id INT,
  IN p_maintenance_type VARCHAR(20),
  IN p_title VARCHAR(100),
  IN p_description TEXT,
  IN p_scheduled_start DATETIME,
  IN p_scheduled_end DATETIME,
  IN p_created_by INT,
  OUT p_maintenance_id INT,
  OUT p_success TINYINT(1),
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_has_conflict TINYINT(1);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = 0;
    SET p_message = 'Terjadi kesalahan sistem.';
  END;
  
  -- Cek konflik dengan booking aktif
  SELECT COUNT(*) > 0 INTO v_has_conflict
  FROM vehicle_blocks vb
  WHERE vb.vehicle_id = p_vehicle_id
    AND vb.block_type = 'booking'
    AND vb.status = 'active'
    AND vb.block_start < p_scheduled_end
    AND vb.block_end > p_scheduled_start;
  
  IF v_has_conflict THEN
    SET p_success = 0;
    SET p_message = 'Jadwal maintenance konflik dengan booking yang sudah ada.';
    SET p_maintenance_id = NULL;
  ELSE
    START TRANSACTION;
    
    -- Insert maintenance record
    INSERT INTO maintenance_records (
      vehicle_id, maintenance_type, title, description,
      scheduled_start, scheduled_end, status, created_by
    ) VALUES (
      p_vehicle_id, p_maintenance_type, p_title, p_description,
      p_scheduled_start, p_scheduled_end, 'scheduled', p_created_by
    );
    
    SET p_maintenance_id = LAST_INSERT_ID();
    
    -- Create vehicle block
    INSERT INTO vehicle_blocks (
      vehicle_id, block_type, reference_id, block_start, block_end, status, reason, created_by
    ) VALUES (
      p_vehicle_id, 'maintenance', p_maintenance_id, p_scheduled_start, p_scheduled_end, 'active', p_title, p_created_by
    );
    
    COMMIT;
    
    SET p_success = 1;
    SET p_message = 'Jadwal maintenance berhasil dibuat.';
  END IF;
  
END//

DELIMITER ;


-- ============================================================
-- 8. EVENT SCHEDULER: Auto-expire pending bookings
-- Jalankan setiap 1 menit
-- ============================================================

-- Aktifkan event scheduler (jalankan sekali sebagai admin)
-- SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS `evt_expire_pending_bookings`;

CREATE EVENT `evt_expire_pending_bookings`
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO
  CALL sp_expire_pending_bookings();


-- ============================================================
-- 9. TRIGGER: Log perubahan status booking ke audit_logs
-- ============================================================

DELIMITER //

DROP TRIGGER IF EXISTS `trg_booking_status_change`//

CREATE TRIGGER `trg_booking_status_change`
AFTER UPDATE ON `bookings`
FOR EACH ROW
BEGIN
  IF OLD.status != NEW.status THEN
    INSERT INTO audit_logs (user_type, action, table_name, record_id, old_values, new_values)
    VALUES (
      'system',
      'status_change',
      'bookings',
      NEW.id,
      JSON_OBJECT('status', OLD.status, 'payment_status', OLD.payment_status),
      JSON_OBJECT('status', NEW.status, 'payment_status', NEW.payment_status)
    );
  END IF;
END//

DELIMITER ;
