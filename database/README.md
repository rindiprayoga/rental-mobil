# 📊 RENTAL MOBIL - DATABASE DESIGN DOCUMENTATION

## Overview

Dokumentasi lengkap desain database untuk sistem **Rental Mobil** yang production-ready dan siap dijadikan portfolio project.

---

## 🏗️ Arsitektur Database

### Tech Stack
- **Database**: MySQL 8+
- **Engine**: InnoDB
- **Charset**: utf8mb4
- **Collation**: utf8mb4_unicode_ci

### Konsep Utama

1. **Vehicle Availability berbasis Block System**
   - Status kendaraan TIDAK disimpan sebagai kolom statis
   - Dihitung realtime dari tabel `vehicle_blocks`
   - Mendukung overlap detection yang akurat

2. **Multi-branch Ready**
   - Desain dari awal mendukung banyak cabang
   - Tidak perlu refactor saat ekspansi

3. **Booking Workflow Otomatis**
   - Pending → Confirmed → In Progress → Completed
   - Auto-expire untuk booking yang tidak dibayar
   - Block otomatis dibatalkan saat expired

---

## 📋 Daftar Tabel

### Phase DB-1 (Core Tables)

| No | Tabel | Fungsi |
|----|-------|--------|
| 1 | `branches` | Data cabang/lokasi rental |
| 2 | `business_hours` | Jam operasional per cabang per hari |
| 3 | `vehicles` | Master data kendaraan |
| 4 | `vehicle_images` | Galeri foto kendaraan |
| 5 | `customers` | Data pelanggan |
| 6 | `bookings` | Header pemesanan |
| 7 | `booking_items` | Detail kendaraan per booking |
| 8 | `vehicle_blocks` ⭐ | **CORE** - Blok jadwal kendaraan |
| 9 | `maintenance_records` | Jadwal & riwayat maintenance |
| 10 | `payments` | Data pembayaran |

### Phase DB-2 (Extension Tables)

| No | Tabel | Fungsi |
|----|-------|--------|
| 11 | `staff_users` | Admin & staff |
| 12 | `reviews` | Ulasan pelanggan |
| 13 | `audit_logs` | Log aktivitas sistem |

---

## 🔗 ERD (Entity Relationship Diagram)

```
┌─────────────────┐
│    branches     │
│─────────────────│
│ id (PK)         │──────────────────────────────────────────┐
│ code            │                                          │
│ name            │                                          │
│ address         │                                          │
│ city            │                                          │
└────────┬────────┘                                          │
         │ 1                                                 │
         │                                                   │
         │ N                                                 │
┌────────▼────────┐      ┌─────────────────┐                 │
│ business_hours  │      │    vehicles     │                 │
│─────────────────│      │─────────────────│                 │
│ id (PK)         │      │ id (PK)         │◄────────────────┤
│ branch_id (FK)  │      │ branch_id (FK)  │─────────────────┘
│ day_of_week     │      │ license_plate   │
│ open_time       │      │ name            │
│ close_time      │      │ type            │
│ cutoff_time     │      │ price_per_day   │
└─────────────────┘      └────────┬────────┘
                                  │ 1
                                  │
                    ┌─────────────┼─────────────┐
                    │ N           │ N           │ N
          ┌─────────▼───────┐ ┌───▼────────┐ ┌──▼───────────────┐
          │ vehicle_images  │ │ reviews    │ │ vehicle_blocks ⭐ │
          │─────────────────│ │────────────│ │──────────────────│
          │ id (PK)         │ │ id (PK)    │ │ id (PK)          │
          │ vehicle_id (FK) │ │ vehicle_id │ │ vehicle_id (FK)  │
          │ image_url       │ │ rating     │ │ block_type       │
          └─────────────────┘ │ comment    │ │ reference_id     │
                              └────────────┘ │ block_start      │
                                             │ block_end        │
                                             │ status           │
                                             └──────────────────┘
                                                      ▲
                                                      │ reference_id
                    ┌─────────────────────────────────┤
                    │                                 │
          ┌─────────┴───────────┐       ┌─────────────┴───────────┐
          │      bookings       │       │  maintenance_records    │
          │─────────────────────│       │─────────────────────────│
          │ id (PK)             │       │ id (PK)                 │
          │ booking_code        │       │ vehicle_id (FK)         │
          │ branch_id (FK)      │       │ maintenance_type        │
          │ customer_id (FK)    │       │ scheduled_start         │
          │ start_datetime      │       │ scheduled_end           │
          │ end_datetime        │       │ status                  │
          │ status              │       └─────────────────────────┘
          │ payment_status      │
          └──────────┬──────────┘
                     │ 1
       ┌─────────────┼─────────────┐
       │ N           │ N           │ N
┌──────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐
│booking_items│ │ payments │ │  reviews   │
│─────────────│ │──────────│ │────────────│
│ id (PK)     │ │ id (PK)  │ │ id (PK)    │
│ booking_id  │ │booking_id│ │ booking_id │
│ vehicle_id  │ │ amount   │ │ rating     │
│ price_per_day│ │ status   │ └────────────┘
└─────────────┘ └──────────┘

┌─────────────────┐
│   customers     │
│─────────────────│
│ id (PK)         │◄─────── bookings.customer_id
│ email           │◄─────── reviews.customer_id
│ phone           │
│ full_name       │
│ id_number       │
└─────────────────┘

┌─────────────────┐
│  staff_users    │
│─────────────────│
│ id (PK)         │
│ branch_id (FK)  │
│ email           │
│ role            │
└─────────────────┘

┌─────────────────┐
│   audit_logs    │
│─────────────────│
│ id (PK)         │
│ user_type       │
│ action          │
│ table_name      │
│ record_id       │
└─────────────────┘
```

---

## 🔑 Detail Tabel Penting

### 1. `vehicle_blocks` ⭐ (CORE TABLE)

Tabel paling penting dalam sistem. Menentukan ketersediaan kendaraan.

```sql
-- Kolom Utama
id            INT          -- Primary Key
vehicle_id    INT          -- FK ke vehicles
block_type    ENUM         -- 'booking', 'maintenance', 'reserved'
reference_id  INT          -- ID booking atau maintenance
block_start   DATETIME     -- Waktu mulai blok
block_end     DATETIME     -- Waktu selesai blok
status        ENUM         -- 'active', 'cancelled', 'completed'
```

**Overlap Rule untuk Cek Availability:**
```sql
-- Kendaraan TIDAK tersedia jika:
block_start < request_end AND block_end > request_start
```

### 2. `bookings` (Header Pemesanan)

```sql
-- Status Flow
'pending'     → Menunggu pembayaran (expires_at aktif)
'confirmed'   → Pembayaran diterima
'in_progress' → Kendaraan sedang disewa
'completed'   → Selesai, kendaraan dikembalikan
'cancelled'   → Dibatalkan
'expired'     → Auto-expire karena tidak bayar
```

### 3. `business_hours` (Jam Operasional)

```sql
-- Contoh Data
branch_id  day_of_week  open_time  close_time  cutoff_time
1          0 (Minggu)   09:00      18:00       17:59
1          1 (Senin)    07:00      22:00       21:59
```

---

## 🔄 Business Logic Flow

### Booking Workflow

```
┌──────────────────────────────────────────────────────────────┐
│                    BOOKING WORKFLOW                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Customer                     System                         │
│     │                            │                           │
│     │ 1. Pilih kendaraan         │                           │
│     │ 2. Pilih tanggal & waktu   │                           │
│     │ 3. Submit booking          │                           │
│     │────────────────────────────▶                           │
│     │                            │                           │
│     │                   ┌────────┴────────┐                  │
│     │                   │ Validasi:       │                  │
│     │                   │ - Jam operasional│                 │
│     │                   │ - Availability   │                 │
│     │                   │ - Customer valid │                 │
│     │                   └────────┬────────┘                  │
│     │                            │                           │
│     │                   ┌────────▼────────┐                  │
│     │                   │ Create:         │                  │
│     │                   │ - Booking       │                  │
│     │                   │ - Booking Items │                  │
│     │                   │ - Vehicle Blocks│                  │
│     │                   │ - expires_at    │                  │
│     │                   └────────┬────────┘                  │
│     │                            │                           │
│     │◀───────────────────────────│                           │
│     │ Status: PENDING            │                           │
│     │ Batas bayar: 15 menit      │                           │
│     │                            │                           │
│     │                            │                           │
│  ┌──┴──┐                         │                           │
│  │     │ Bayar dalam 15 menit?   │                           │
│  └──┬──┘                         │                           │
│     │                            │                           │
│  ┌──▼───────────────────┐   ┌────▼────────────────┐          │
│  │ YA - Pembayaran OK   │   │ TIDAK - Timeout     │          │
│  │                      │   │                     │          │
│  │ Status: CONFIRMED    │   │ Status: EXPIRED     │          │
│  │ Block: tetap active  │   │ Block: cancelled    │          │
│  └──────────────────────┘   └─────────────────────┘          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Cutoff Time Logic

```
┌─────────────────────────────────────────────────────────┐
│ ATURAN CUTOFF TIME                                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Jam operasional: 07:00 - 22:00                          │
│ Cutoff return:   21:59                                  │
│                                                         │
│ Contoh:                                                 │
│ ─────────────────────────────────────────               │
│ Booking: Senin 09:00, durasi 1 hari                     │
│ Hasil:   start = Senin 09:00                            │
│          end   = Senin 21:59  ← otomatis cutoff         │
│                                                         │
│ Booking: Senin 09:00, durasi 3 hari                     │
│ Hasil:   start = Senin 09:00                            │
│          end   = Rabu 21:59   ← otomatis cutoff         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Struktur File Database

```
database/
├── schema.sql           # CREATE TABLE lengkap + seed data
├── queries.sql          # Query penting (availability, dashboard, dll)
├── business_logic.sql   # Stored procedures, functions, triggers
└── README.md            # Dokumentasi ini
```

---

## 🚀 Roadmap Implementasi

### Phase 1: Database Core (Week 1-2)
- [x] Desain ERD
- [x] Create schema.sql
- [x] Create seed data
- [ ] Setup MySQL server
- [ ] Import schema & seed

### Phase 2: Backend API (Week 3-5)
- [ ] Setup Node.js/Express atau framework pilihan
- [ ] Implement CRUD vehicles
- [ ] Implement availability check
- [ ] Implement booking flow
- [ ] Implement payment integration

### Phase 3: Admin Dashboard (Week 6-7)
- [ ] Dashboard overview
- [ ] Vehicle management
- [ ] Booking management
- [ ] Customer management
- [ ] Reports

### Phase 4: Frontend Integration (Week 8-9)
- [ ] Connect React frontend ke API
- [ ] Implement booking flow di frontend
- [ ] Real-time availability check
- [ ] Payment gateway integration

### Phase 5: Production Ready (Week 10)
- [ ] Testing & bug fixes
- [ ] Performance optimization
- [ ] Security audit
- [ ] Deployment

---

## ⚠️ Catatan Penting

### 1. Index Strategy
- Index komposit `idx_vehicle_blocks_availability` sangat critical untuk performance
- Pastikan query availability selalu menggunakan index ini

### 2. Event Scheduler
- Aktifkan MySQL Event Scheduler untuk auto-expire:
  ```sql
  SET GLOBAL event_scheduler = ON;
  ```

### 3. Timezone
- Pastikan server MySQL dan aplikasi menggunakan timezone yang sama
- Rekomendasi: `Asia/Jakarta` atau `UTC`

### 4. Backup Strategy
- Backup harian untuk tabel transaksi
- Backup mingguan full database

---

## 👨‍💻 Penggunaan

### Import Schema
```bash
mysql -u root -p rental_mobil < database/schema.sql
mysql -u root -p rental_mobil < database/queries.sql
mysql -u root -p rental_mobil < database/business_logic.sql
```

### Test Availability Query
```sql
CALL sp_get_available_vehicles(
  1,                          -- branch_id
  '2026-02-15 08:00:00',      -- request_start
  '2026-02-15 21:59:00',      -- request_end
  'MPV',                      -- vehicle_type (opsional)
  7                           -- min_capacity (opsional)
);
```

### Test Create Booking
```sql
CALL sp_create_booking(
  1,                          -- branch_id
  1,                          -- customer_id
  '[1, 2]',                   -- vehicle_ids (JSON array)
  '2026-02-15 08:00:00',      -- start_datetime
  1,                          -- total_days
  'Booking untuk liburan',    -- notes
  @booking_id,
  @booking_code,
  @error_message
);

SELECT @booking_id, @booking_code, @error_message;
```

---

## 📞 Support

Jika ada pertanyaan atau butuh bantuan, silakan buat issue di repository ini.

---

*Dokumentasi ini dibuat sebagai bagian dari project Rental Mobil untuk portfolio.*
