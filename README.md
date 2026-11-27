# CerdasCanteen — Aplikasi Pemesanan Makanan Kantin Kampus

Proyek Ujian Akhir Semester (Project-Based Learning)  
**Mata Kuliah:** Pengembangan Aplikasi Perangkat Bergerak (A)  
**Program Studi:** Sistem Informasi, FMIPA Universitas Tanjungpura (Semester Ganjil 2026/2027)  
**Dosen Pengampu:** Syahru Rahmayuda, S.Kom., M.Kom.

---

## Anggota Kelompok 1
| Peran | Nama / NIM | Branch | Fokus Pengerjaan |
| :--- | :--- | :--- | :--- |
| **Anggota 1 (Lead Developer)** | *Nabil Nur Fauzan* | `anggota-1` | Arsitektur, Navigasi, `setState`, `Provider`, Async, Backend Auth MySQL, Build & README |
| **Anggota 2 (UI/UX & Data)** | *Athallah Rizky Erin Saputra* | `anggota-2` | Tema & Layout Responsif, List Dinamis, REST API, SQLite, SharedPreferences, ERD & Slide |
| **Anggota 3 (QA, Native & Bisnis)** | *Marcello Chrisdiantoro* | `anggota-3` | Local Notification, Hardware, Fitur Inovatif, Testing/TDD, Analisis Bisnis, Laporan & Video |

---

## Latar Belakang & Solusi
Antrian kantin kampus sangat panjang saat jam istirahat sehingga mahasiswa kehilangan waktu dan penjual kesulitan mencatat pesanan. **CerdasCanteen** hadir sebagai aplikasi mobile berbasis Flutter agar mahasiswa dapat melihat daftar menu dinamis dari API, memesan melalui keranjang terintegrasi, memantau riwayat transaksi lokal, dan menerima notifikasi status pesanan (*Diproses* / *Selesai*).

---

## Struktur Proyek
```text
├── backend/                  # REST API PHP + skema MySQL (Tugas 11)
│   ├── database.sql
│   ├── config.php
│   ├── register.php
│   └── login.php
├── dart_basics/              # Program Dart konsol (Tugas 2a-2c & Tugas 8)
├── docs/                     # Dokumentasi arsitektur, analisis bisnis & ERD
├── lib/
│   ├── main.dart             # Entry point, MultiProvider & proteksi halaman
│   ├── models/               # Model data (User, Menu, Cart, Order)
│   ├── providers/            # State global (AuthProvider, CartProvider)
│   ├── routes/               # Named routes & Route Guard
│   ├── screens/              # Halaman UI (Login, Register, Main, Detail, Cart, Checkout)
│   ├── services/             # AuthService, ApiService, DB Lokal, Notifikasi
│   ├── theme/                # Tema warna & tipografi
│   ├── utils/                # Helper & modul TDD
│   └── widgets/              # Komponen widget reusable
└── test/                     # Unit Test, Widget Test & TDD (Tugas 13)
```

---

## Cara Instalasi & Menjalankan Aplikasi

### 1. Menjalankan Aplikasi Flutter (FlutLab.io / Lokal)
1. Clone repository ini atau buka proyek pada **FlutLab.io**.
2. Instal dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```
4. **Akun Demo (Mode Demo):**
   * **Email:** `mahasiswa@untan.ac.id`
   * **Password:** `123456`

### 2. Menjalankan Backend PHP + MySQL (Laragon / XAMPP)
1. Salin folder `backend/` ke `C:\laragon\www\cerdascanteen_api\` (Laragon) atau `C:\xampp\htdocs\cerdascanteen_api\` (XAMPP).
2. Nyalakan service **Apache** dan **MySQL**.
3. Buka `http://localhost/phpmyadmin` lalu **Import** file `backend/database.sql` (membuat database `cerdascanteen_db` beserta tabel `users` dan `orders`).
4. Untuk menghubungkan aplikasi Flutter langsung ke server MySQL, ubah konfigurasi di `lib/services/auth_service.dart`:
   ```dart
   static const bool useDemoMode = false;
   static const String baseUrl = 'http://localhost/cerdascanteen_api';
   ```

---

## Download Aplikasi (Android APK)

[![Download APK](https://img.shields.io/badge/Download-Android%20APK%20(ARM64)-007F5F?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Kings-Bilbil/CerdasCanteen/releases/download/1.0.0/uas_perak.apk)

- **Tautan Langsung:** [Download CerdasCanteen v1.0.0 — Android ARM64 (.apk)](https://github.com/Kings-Bilbil/CerdasCanteen/releases/download/1.0.0/uas_perak.apk)
- **Cara Instal di HP Android:** Unduh file `.apk` → buka file → izinkan *Install from unknown sources* jika diminta → login memakai akun demo (`mahasiswa@untan.ac.id` / `123456`) atau daftar akun baru.

