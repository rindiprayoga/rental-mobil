-- ============================================================
-- RENTAL MOBIL - DATABASE SCHEMA
-- Database: MySQL 8+
-- Engine: InnoDB
-- Charset: utf8mb4
-- Author: Rental Mobil Team
-- Created: 2026-02-10
-- ============================================================

-- ============================================================
-- A) PHASE DB-1: TABEL INTI
-- ============================================================
-- 
-- 1. branches          : Data cabang/lokasi rental
-- 2. business_hours    : Jam operasional per cabang per hari
-- 3. vehicles          : Data kendaraan (mobil)
-- 4. vehicle_images    : Galeri foto kendaraan
-- 5. customers         : Data pelanggan
-- 6. bookings          : Data pemesanan (header)
-- 7. booking_items     : Detail item booking (kendaraan yang disewa)
-- 8. vehicle_blocks    : Blok jadwal kendaraan (CORE untuk availability)
-- 9. maintenance_records: Jadwal & riwayat maintenance kendaraan
-- 10. payments         : Data pembayaran
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. BRANCHES (Cabang)
-- ============================================================
-- Fungsi: Menyimpan data lokasi/cabang rental.
-- Desain siap multi-branch tanpa refactor.
-- ============================================================

DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(10) NOT NULL COMMENT 'Kode unik cabang, misal: JKT01',
  `name` VARCHAR(100) NOT NULL COMMENT 'Nama cabang',
  `address` TEXT NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `province` VARCHAR(100) NOT NULL,
  `postal_code` VARCHAR(10) DEFAULT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  `latitude` DECIMAL(10, 8) DEFAULT NULL,
  `longitude` DECIMAL(11, 8) DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_branches_code` (`code`),
  INDEX `idx_branches_city` (`city`),
  INDEX `idx_branches_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. BUSINESS_HOURS (Jam Operasional)
-- ============================================================
-- Fungsi: Menyimpan jam buka-tutup per cabang per hari.
-- Mendukung variasi jam operasional tiap hari.
-- ============================================================

DROP TABLE IF EXISTS `business_hours`;
CREATE TABLE `business_hours` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `branch_id` INT UNSIGNED NOT NULL,
  `day_of_week` TINYINT UNSIGNED NOT NULL COMMENT '0=Minggu, 1=Senin, ..., 6=Sabtu',
  `open_time` TIME NOT NULL DEFAULT '07:00:00',
  `close_time` TIME NOT NULL DEFAULT '22:00:00',
  `cutoff_time` TIME NOT NULL DEFAULT '21:59:00' COMMENT 'Batas waktu pengembalian',
  `is_closed` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Jika tutup di hari tertentu',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_business_hours_branch_day` (`branch_id`, `day_of_week`),
  CONSTRAINT `fk_business_hours_branch` FOREIGN KEY (`branch_id`) 
    REFERENCES `branches` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. VEHICLES (Kendaraan)
-- ============================================================
-- Fungsi: Master data kendaraan yang tersedia untuk disewa.
-- Status kendaraan TIDAK disimpan di sini, dihitung dari vehicle_blocks.
-- ============================================================

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `branch_id` INT UNSIGNED NOT NULL COMMENT 'Cabang pemilik kendaraan',
  `license_plate` VARCHAR(15) NOT NULL COMMENT 'Nomor plat, unik',
  `name` VARCHAR(100) NOT NULL COMMENT 'Nama model, misal: Toyota Avanza',
  `brand` VARCHAR(50) NOT NULL COMMENT 'Merek: Toyota, Honda, dll',
  `model` VARCHAR(50) NOT NULL COMMENT 'Model: Avanza, Innova, dll',
  `year` YEAR NOT NULL COMMENT 'Tahun produksi',
  `color` VARCHAR(30) NOT NULL,
  `type` ENUM('MPV', 'SUV', 'Sedan', 'Hatchback', 'Van') NOT NULL DEFAULT 'MPV',
  `transmission` ENUM('Automatic', 'Manual') NOT NULL DEFAULT 'Automatic',
  `fuel_type` ENUM('Bensin', 'Diesel', 'Hybrid', 'Electric') NOT NULL DEFAULT 'Bensin',
  `capacity` TINYINT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Kapasitas penumpang',
  `luggage_capacity` TINYINT UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Kapasitas bagasi (koper)',
  `price_per_day` DECIMAL(12, 2) NOT NULL COMMENT 'Harga sewa per hari (IDR)',
  `description` TEXT DEFAULT NULL,
  `features` JSON DEFAULT NULL COMMENT 'Fitur: AC, Audio, GPS, dll',
  `image_url` VARCHAR(255) DEFAULT NULL COMMENT 'Foto utama',
  `is_featured` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Tampil di halaman utama',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Aktif untuk disewakan',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_vehicles_license_plate` (`license_plate`),
  INDEX `idx_vehicles_branch` (`branch_id`),
  INDEX `idx_vehicles_type` (`type`),
  INDEX `idx_vehicles_price` (`price_per_day`),
  INDEX `idx_vehicles_is_active` (`is_active`),
  INDEX `idx_vehicles_is_featured` (`is_featured`),
  INDEX `idx_vehicles_capacity` (`capacity`),
  CONSTRAINT `fk_vehicles_branch` FOREIGN KEY (`branch_id`) 
    REFERENCES `branches` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. VEHICLE_IMAGES (Galeri Foto Kendaraan)
-- ============================================================
-- Fungsi: Menyimpan multiple foto per kendaraan.
-- ============================================================

DROP TABLE IF EXISTS `vehicle_images`;
CREATE TABLE `vehicle_images` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `alt_text` VARCHAR(100) DEFAULT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_vehicle_images_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_vehicle_images_vehicle` FOREIGN KEY (`vehicle_id`) 
    REFERENCES `vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. CUSTOMERS (Pelanggan)
-- ============================================================
-- Fungsi: Data pelanggan yang melakukan booking.
-- ============================================================

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `password_hash` VARCHAR(255) DEFAULT NULL COMMENT 'Null jika guest checkout',
  `full_name` VARCHAR(100) NOT NULL,
  `id_type` ENUM('KTP', 'SIM', 'Passport') NOT NULL DEFAULT 'KTP',
  `id_number` VARCHAR(50) NOT NULL COMMENT 'Nomor identitas',
  `id_image_url` VARCHAR(255) DEFAULT NULL COMMENT 'Foto KTP/SIM',
  `address` TEXT DEFAULT NULL,
  `city` VARCHAR(100) DEFAULT NULL,
  `date_of_birth` DATE DEFAULT NULL,
  `sim_number` VARCHAR(50) DEFAULT NULL COMMENT 'Nomor SIM untuk verifikasi',
  `sim_expiry` DATE DEFAULT NULL,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_blacklisted` TINYINT(1) NOT NULL DEFAULT 0,
  `blacklist_reason` TEXT DEFAULT NULL,
  `notes` TEXT DEFAULT NULL COMMENT 'Catatan internal',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_customers_email` (`email`),
  UNIQUE KEY `uk_customers_id_number` (`id_number`),
  INDEX `idx_customers_phone` (`phone`),
  INDEX `idx_customers_is_verified` (`is_verified`),
  INDEX `idx_customers_is_blacklisted` (`is_blacklisted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. BOOKINGS (Pemesanan - Header)
-- ============================================================
-- Fungsi: Data header pemesanan/booking.
-- Status: pending → confirmed → completed / cancelled / expired
-- ============================================================

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_code` VARCHAR(20) NOT NULL COMMENT 'Kode booking unik, misal: BK20260210001',
  `branch_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `booking_date` DATE NOT NULL COMMENT 'Tanggal booking dibuat',
  `start_datetime` DATETIME NOT NULL COMMENT 'Waktu mulai sewa',
  `end_datetime` DATETIME NOT NULL COMMENT 'Waktu selesai sewa (auto cutoff)',
  `total_days` INT UNSIGNED NOT NULL DEFAULT 1,
  `subtotal` DECIMAL(14, 2) NOT NULL DEFAULT 0 COMMENT 'Total harga kendaraan',
  `discount_amount` DECIMAL(14, 2) NOT NULL DEFAULT 0,
  `tax_amount` DECIMAL(14, 2) NOT NULL DEFAULT 0,
  `total_amount` DECIMAL(14, 2) NOT NULL DEFAULT 0 COMMENT 'Grand total',
  `deposit_amount` DECIMAL(14, 2) NOT NULL DEFAULT 0 COMMENT 'Uang jaminan',
  `status` ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'expired') 
    NOT NULL DEFAULT 'pending',
  `payment_status` ENUM('unpaid', 'partial', 'paid', 'refunded') NOT NULL DEFAULT 'unpaid',
  `expires_at` DATETIME DEFAULT NULL COMMENT 'Batas waktu pembayaran pending',
  `confirmed_at` DATETIME DEFAULT NULL,
  `cancelled_at` DATETIME DEFAULT NULL,
  `cancellation_reason` TEXT DEFAULT NULL,
  `pickup_location` TEXT DEFAULT NULL COMMENT 'Lokasi pengambilan jika berbeda',
  `dropoff_location` TEXT DEFAULT NULL COMMENT 'Lokasi pengembalian jika berbeda',
  `notes` TEXT DEFAULT NULL COMMENT 'Catatan dari customer',
  `admin_notes` TEXT DEFAULT NULL COMMENT 'Catatan internal admin',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bookings_code` (`booking_code`),
  INDEX `idx_bookings_branch` (`branch_id`),
  INDEX `idx_bookings_customer` (`customer_id`),
  INDEX `idx_bookings_status` (`status`),
  INDEX `idx_bookings_payment_status` (`payment_status`),
  INDEX `idx_bookings_start_datetime` (`start_datetime`),
  INDEX `idx_bookings_end_datetime` (`end_datetime`),
  INDEX `idx_bookings_expires_at` (`expires_at`),
  INDEX `idx_bookings_booking_date` (`booking_date`),
  CONSTRAINT `fk_bookings_branch` FOREIGN KEY (`branch_id`) 
    REFERENCES `branches` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_bookings_customer` FOREIGN KEY (`customer_id`) 
    REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. BOOKING_ITEMS (Detail Booking - Kendaraan)
-- ============================================================
-- Fungsi: Detail kendaraan yang disewa dalam satu booking.
-- Mendukung booking multiple kendaraan sekaligus.
-- ============================================================

DROP TABLE IF EXISTS `booking_items`;
CREATE TABLE `booking_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_id` INT UNSIGNED NOT NULL,
  `vehicle_id` INT UNSIGNED NOT NULL,
  `price_per_day` DECIMAL(12, 2) NOT NULL COMMENT 'Harga saat booking (snapshot)',
  `total_days` INT UNSIGNED NOT NULL DEFAULT 1,
  `subtotal` DECIMAL(14, 2) NOT NULL COMMENT 'price_per_day × total_days',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_booking_items_booking_vehicle` (`booking_id`, `vehicle_id`),
  INDEX `idx_booking_items_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_booking_items_booking` FOREIGN KEY (`booking_id`) 
    REFERENCES `bookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_booking_items_vehicle` FOREIGN KEY (`vehicle_id`) 
    REFERENCES `vehicles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. VEHICLE_BLOCKS ⭐ (Blok Jadwal Kendaraan - CORE)
-- ============================================================
-- Fungsi: TABEL INTI untuk menentukan availability kendaraan.
-- Setiap booking/maintenance membuat block di tabel ini.
-- Status kendaraan dihitung dari overlap block dengan waktu request.
-- 
-- Block Types:
-- - booking   : Blok dari booking customer
-- - maintenance: Blok dari jadwal maintenance
-- - reserved  : Blok manual oleh admin
-- 
-- Block Status:
-- - active    : Blok aktif (kendaraan tidak tersedia)
-- - cancelled : Blok dibatalkan
-- - completed : Blok selesai (sudah lewat)
-- ============================================================

DROP TABLE IF EXISTS `vehicle_blocks`;
CREATE TABLE `vehicle_blocks` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` INT UNSIGNED NOT NULL,
  `block_type` ENUM('booking', 'maintenance', 'reserved') NOT NULL,
  `reference_id` INT UNSIGNED DEFAULT NULL COMMENT 'ID booking atau maintenance',
  `block_start` DATETIME NOT NULL COMMENT 'Waktu mulai blok',
  `block_end` DATETIME NOT NULL COMMENT 'Waktu selesai blok',
  `status` ENUM('active', 'cancelled', 'completed') NOT NULL DEFAULT 'active',
  `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Alasan blok (untuk reserved/maintenance)',
  `created_by` INT UNSIGNED DEFAULT NULL COMMENT 'User ID yang membuat blok',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_vehicle_blocks_vehicle` (`vehicle_id`),
  INDEX `idx_vehicle_blocks_type` (`block_type`),
  INDEX `idx_vehicle_blocks_status` (`status`),
  INDEX `idx_vehicle_blocks_start` (`block_start`),
  INDEX `idx_vehicle_blocks_end` (`block_end`),
  INDEX `idx_vehicle_blocks_reference` (`block_type`, `reference_id`),
  -- Index komposit untuk query availability (CRITICAL!)
  INDEX `idx_vehicle_blocks_availability` (`vehicle_id`, `status`, `block_start`, `block_end`),
  CONSTRAINT `fk_vehicle_blocks_vehicle` FOREIGN KEY (`vehicle_id`) 
    REFERENCES `vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. MAINTENANCE_RECORDS (Jadwal & Riwayat Maintenance)
-- ============================================================
-- Fungsi: Menyimpan jadwal dan riwayat perawatan kendaraan.
-- Setiap maintenance membuat block di vehicle_blocks.
-- ============================================================

DROP TABLE IF EXISTS `maintenance_records`;
CREATE TABLE `maintenance_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` INT UNSIGNED NOT NULL,
  `maintenance_type` ENUM('scheduled', 'repair', 'inspection', 'cleaning') NOT NULL,
  `title` VARCHAR(100) NOT NULL COMMENT 'Judul maintenance',
  `description` TEXT DEFAULT NULL,
  `scheduled_start` DATETIME NOT NULL,
  `scheduled_end` DATETIME NOT NULL,
  `actual_start` DATETIME DEFAULT NULL,
  `actual_end` DATETIME DEFAULT NULL,
  `cost` DECIMAL(14, 2) DEFAULT NULL COMMENT 'Biaya maintenance',
  `vendor_name` VARCHAR(100) DEFAULT NULL COMMENT 'Nama bengkel/vendor',
  `status` ENUM('scheduled', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
  `notes` TEXT DEFAULT NULL,
  `created_by` INT UNSIGNED DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_maintenance_vehicle` (`vehicle_id`),
  INDEX `idx_maintenance_type` (`maintenance_type`),
  INDEX `idx_maintenance_status` (`status`),
  INDEX `idx_maintenance_scheduled` (`scheduled_start`, `scheduled_end`),
  CONSTRAINT `fk_maintenance_vehicle` FOREIGN KEY (`vehicle_id`) 
    REFERENCES `vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. PAYMENTS (Pembayaran)
-- ============================================================
-- Fungsi: Menyimpan data pembayaran booking.
-- Mendukung pembayaran bertahap (partial payment).
-- ============================================================

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `payment_code` VARCHAR(30) NOT NULL COMMENT 'Kode pembayaran unik',
  `booking_id` INT UNSIGNED NOT NULL,
  `amount` DECIMAL(14, 2) NOT NULL,
  `payment_method` ENUM('cash', 'bank_transfer', 'credit_card', 'debit_card', 'e_wallet', 'qris') 
    NOT NULL,
  `payment_channel` VARCHAR(50) DEFAULT NULL COMMENT 'Nama bank/e-wallet',
  `transaction_id` VARCHAR(100) DEFAULT NULL COMMENT 'ID transaksi dari payment gateway',
  `status` ENUM('pending', 'success', 'failed', 'expired', 'refunded') NOT NULL DEFAULT 'pending',
  `paid_at` DATETIME DEFAULT NULL,
  `expired_at` DATETIME DEFAULT NULL,
  `refunded_at` DATETIME DEFAULT NULL,
  `refund_amount` DECIMAL(14, 2) DEFAULT NULL,
  `refund_reason` TEXT DEFAULT NULL,
  `payment_proof_url` VARCHAR(255) DEFAULT NULL COMMENT 'Bukti transfer',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_payments_code` (`payment_code`),
  INDEX `idx_payments_booking` (`booking_id`),
  INDEX `idx_payments_status` (`status`),
  INDEX `idx_payments_method` (`payment_method`),
  INDEX `idx_payments_paid_at` (`paid_at`),
  INDEX `idx_payments_transaction` (`transaction_id`),
  CONSTRAINT `fk_payments_booking` FOREIGN KEY (`booking_id`) 
    REFERENCES `bookings` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PHASE DB-2: TABEL OPSIONAL (UNTUK PENGEMBANGAN)
-- ============================================================

-- ============================================================
-- 11. STAFF_USERS (Admin & Staff)
-- ============================================================

DROP TABLE IF EXISTS `staff_users`;
CREATE TABLE `staff_users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `branch_id` INT UNSIGNED DEFAULT NULL COMMENT 'Null = akses semua cabang',
  `email` VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `role` ENUM('super_admin', 'branch_admin', 'staff', 'finance') NOT NULL DEFAULT 'staff',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `last_login_at` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_staff_email` (`email`),
  INDEX `idx_staff_branch` (`branch_id`),
  INDEX `idx_staff_role` (`role`),
  INDEX `idx_staff_is_active` (`is_active`),
  CONSTRAINT `fk_staff_branch` FOREIGN KEY (`branch_id`) 
    REFERENCES `branches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. REVIEWS (Ulasan Pelanggan)
-- ============================================================

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `vehicle_id` INT UNSIGNED NOT NULL,
  `rating` TINYINT UNSIGNED NOT NULL COMMENT '1-5 stars',
  `comment` TEXT DEFAULT NULL,
  `is_published` TINYINT(1) NOT NULL DEFAULT 1,
  `admin_reply` TEXT DEFAULT NULL,
  `replied_at` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_reviews_booking` (`booking_id`),
  INDEX `idx_reviews_customer` (`customer_id`),
  INDEX `idx_reviews_vehicle` (`vehicle_id`),
  INDEX `idx_reviews_rating` (`rating`),
  INDEX `idx_reviews_is_published` (`is_published`),
  CONSTRAINT `fk_reviews_booking` FOREIGN KEY (`booking_id`) 
    REFERENCES `bookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_customer` FOREIGN KEY (`customer_id`) 
    REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_vehicle` FOREIGN KEY (`vehicle_id`) 
    REFERENCES `vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_reviews_rating` CHECK (`rating` >= 1 AND `rating` <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. AUDIT_LOGS (Log Aktivitas)
-- ============================================================

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_type` ENUM('customer', 'staff', 'system') NOT NULL,
  `user_id` INT UNSIGNED DEFAULT NULL,
  `action` VARCHAR(50) NOT NULL COMMENT 'create, update, delete, login, logout, dll',
  `table_name` VARCHAR(50) DEFAULT NULL,
  `record_id` INT UNSIGNED DEFAULT NULL,
  `old_values` JSON DEFAULT NULL,
  `new_values` JSON DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_audit_user` (`user_type`, `user_id`),
  INDEX `idx_audit_action` (`action`),
  INDEX `idx_audit_table` (`table_name`, `record_id`),
  INDEX `idx_audit_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- DATA AWAL (SEED DATA)
-- ============================================================

-- Insert cabang utama
INSERT INTO `branches` (`code`, `name`, `address`, `city`, `province`, `phone`, `email`) VALUES
('JKT01', 'RentDrive Jakarta Pusat', 'Jl. Sudirman No. 123', 'Jakarta Pusat', 'DKI Jakarta', '021-5551234', 'jakarta@rentdrive.com');

-- Insert jam operasional (Senin-Sabtu: 07:00-22:00, Minggu: 09:00-18:00)
INSERT INTO `business_hours` (`branch_id`, `day_of_week`, `open_time`, `close_time`, `cutoff_time`, `is_closed`) VALUES
(1, 0, '09:00:00', '18:00:00', '17:59:00', 0),  -- Minggu
(1, 1, '07:00:00', '22:00:00', '21:59:00', 0),  -- Senin
(1, 2, '07:00:00', '22:00:00', '21:59:00', 0),  -- Selasa
(1, 3, '07:00:00', '22:00:00', '21:59:00', 0),  -- Rabu
(1, 4, '07:00:00', '22:00:00', '21:59:00', 0),  -- Kamis
(1, 5, '07:00:00', '22:00:00', '21:59:00', 0),  -- Jumat
(1, 6, '07:00:00', '22:00:00', '21:59:00', 0);  -- Sabtu

-- Insert sample vehicles (sesuai data dari frontend)
INSERT INTO `vehicles` (`branch_id`, `license_plate`, `name`, `brand`, `model`, `year`, `color`, `type`, `transmission`, `fuel_type`, `capacity`, `price_per_day`, `is_featured`, `image_url`) VALUES
(1, 'B 1234 ABC', 'Toyota Alphard', 'Toyota', 'Alphard', 2023, 'Putih', 'MPV', 'Automatic', 'Bensin', 7, 1500000.00, 1, 'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800'),
(1, 'B 2345 DEF', 'Honda CR-V', 'Honda', 'CR-V', 2023, 'Hitam', 'SUV', 'Automatic', 'Bensin', 5, 950000.00, 1, 'https://images.unsplash.com/photo-1568844293986-8c1a5c4fe939?w=800'),
(1, 'B 3456 GHI', 'Toyota Innova', 'Toyota', 'Innova Zenix', 2024, 'Silver', 'MPV', 'Automatic', 'Bensin', 7, 850000.00, 1, 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800'),
(1, 'B 4567 JKL', 'Mitsubishi Pajero', 'Mitsubishi', 'Pajero Sport', 2023, 'Putih', 'SUV', 'Automatic', 'Diesel', 7, 1200000.00, 1, 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800'),
(1, 'B 5678 MNO', 'Hyundai Stargazer', 'Hyundai', 'Stargazer', 2024, 'Abu-abu', 'MPV', 'Automatic', 'Bensin', 7, 750000.00, 0, 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800'),
(1, 'B 6789 PQR', 'Mazda CX-5', 'Mazda', 'CX-5', 2023, 'Merah', 'SUV', 'Automatic', 'Bensin', 5, 1000000.00, 0, 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800'),
(1, 'B 7890 STU', 'Toyota Avanza', 'Toyota', 'Avanza', 2023, 'Silver', 'MPV', 'Manual', 'Bensin', 7, 550000.00, 0, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800'),
(1, 'B 8901 VWX', 'Honda Civic', 'Honda', 'Civic', 2023, 'Hitam', 'Sedan', 'Automatic', 'Bensin', 5, 700000.00, 0, 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800'),
(1, 'B 9012 YZA', 'Toyota Camry', 'Toyota', 'Camry', 2023, 'Hitam', 'Sedan', 'Automatic', 'Hybrid', 5, 900000.00, 0, 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800');

-- Insert sample admin
INSERT INTO `staff_users` (`email`, `password_hash`, `full_name`, `phone`, `role`) VALUES
('admin@rentdrive.com', '$2a$10$placeholder_hash_here', 'Administrator', '08123456789', 'super_admin');
