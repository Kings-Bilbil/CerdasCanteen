# CerdasCanteen

> Aplikasi pemesanan makanan kantin kampus berbasis Flutter.

CerdasCanteen membantu mahasiswa melihat menu, memesan makanan tanpa antre panjang, memantau pesanan, dan melihat riwayat transaksi. Proyek ini dibuat untuk UAS Pengembangan Aplikasi Perangkat Bergerak (A), Sistem Informasi, FMIPA Universitas Tanjungpura, Semester Ganjil 2026/2027.

## Anggota Kelompok

| Peran | Nama / NIM | Branch | Fokus |
|---|---|---|---|
| Lead Developer | Nabil Nur Fauzan / H1101241046 | `anggota-1` | Arsitektur, navigasi, Provider, autentikasi, backend |
| UI/UX & Data | Atthallah Rizki Erin / H1101241042 | `anggota-2` | UI, REST API, SQLite, SharedPreferences, tema |
| QA & Dokumentasi | Marcello Chrisdiantoro / H1101241041 | `anggota-3` | Testing, TDD, analisis bisnis, dokumentasi |

## Fitur Utama

- Login dan registrasi mahasiswa dengan mode demo.
- Daftar menu dinamis, pencarian, filter kategori, dan detail menu.
- Keranjang dengan jumlah, catatan, take-away, dan ekstra pedas.
- Perhitungan subtotal dan total pembayaran.
- Checkout asinkron dengan simulasi timeout/offline.
- Kode pesanan dan riwayat transaksi.
- SQLite pada perangkat dan mode pratinjau web di FlutLab.
- Tema terang/gelap dan penyimpanan preferensi.
- 37 unit test dan widget test yang menguji kode asli di `lib/`.

## Teknologi

Flutter, Dart, Provider, `http`, `sqflite`, `path`, `shared_preferences`, `intl`, dan `flutter_test`.

## Menjalankan di FlutLab.io

FlutLab dapat digunakan tanpa instalasi Android Studio atau Android SDK.

1. Buka [flutlab.io](https://flutlab.io/) dan login.
2. Pilih **Create New Project** atau **Import Project from GitHub**.
3. Masukkan repository `https://github.com/Kings-Bilbil/CerdasCanteen.git`.
4. Pilih branch `master` untuk kode gabungan atau `anggota-3` untuk branch QA.
5. Tunggu proses import selesai.
6. Buka Terminal FlutLab dan jalankan:

```bash
flutter pub get
```

Batas SDK dibuat longgar agar kompatibel dengan Flutter di FlutLab:

```yaml
sdk: ">=3.0.0 <4.0.0"
flutter: ">=3.10.0"
```

### Menjalankan aplikasi

Gunakan tombol **Run**, atau jalankan:

```bash
flutter run
```

Untuk Web Preview, pilih perangkat web yang tersedia di FlutLab. Mode demo aktif secara default sehingga backend tidak diperlukan.

### Akun demo

```text
Email    : mahasiswa@untan.ac.id
Password : 123456
```

## Menjalankan Testing di FlutLab

Test mengimpor kode produksi dari `lib/`, bukan salinan kode di folder fixture.

### Semua test

```bash
flutter test
```

Hasil yang diharapkan:

```text
00:06 +37: All tests passed!
```

### Test per file

```bash
flutter test test/queue_estimator_test.dart
flutter test test/order_total_test.dart
flutter test test/json_parsing_test.dart
flutter test test/validators_test.dart
flutter test test/form_widget_test.dart
```

### Analisis kode

```bash
flutter analyze
```

### Cara membaca test gagal

Setiap `expect` memiliki `reason` dengan format:

```text
INPUT <data> -> HARAP <hasil>. Bila gagal: <kemungkinan penyebab>.
```

Jika muncul `Expected` dan `Actual`, baca bagian `INPUT`, `HARAP`, dan `Bila gagal` untuk mengetahui data uji, hasil yang diharapkan, serta kemungkinan lokasi masalah.

## Bukti TDD

Fitur estimasi antrean dikerjakan dengan urutan test → RED → implementasi → GREEN → RED validasi → GREEN → REFACTOR. Log tersedia di:

```text
docs/tdd/01_red.log
docs/tdd/02_green.log
docs/tdd/03_red.log
docs/tdd/04_green.log
docs/tdd/05_refactor.log
```

Test utama TDD tetap memiliki lima test dengan nama asli agar sesuai dengan log historis.

## Struktur Project

```text
backend/                 REST API PHP dan skema MySQL
dart_basics/             Latihan dasar Dart
lib/
  models/                Model menu, user, keranjang, transaksi
  providers/             AuthProvider, CartProvider, ThemeProvider
  routes/                Named routes dan route guard
  screens/               Layar aplikasi
  services/              API, autentikasi, database, preferensi
  theme/                 Tema aplikasi
  utils/                 Modul estimasi antrean
  widgets/               Widget reusable
test/                    Unit test dan widget test
docs/tdd/                Log bukti proses TDD
```

## Backend Opsional

Mode demo adalah konfigurasi bawaan. Untuk mencoba backend PHP MySQL:

1. Salin `backend/` ke `C:\laragon\www\cerdascanteen_api\` atau folder XAMPP.
2. Nyalakan Apache dan MySQL.
3. Import `backend/database.sql` melalui phpMyAdmin.
4. Ubah `lib/services/auth_service.dart`:

```dart
static const bool useDemoMode = false;
static const String baseUrl = 'http://localhost/cerdascanteen_api';
```

Pada Android fisik, ganti `localhost` dengan IP komputer server. Pada FlutLab gunakan URL server yang dapat diakses dari internet atau tetap gunakan mode demo.

## Catatan Platform

SQLite berjalan pada Android, iOS, dan macOS. Pada Web Preview FlutLab, aplikasi memakai cache pratinjau di memori karena SQLite tidak tersedia secara langsung. Data pratinjau dapat hilang ketika halaman dimuat ulang.

## Repository

- GitHub: <https://github.com/Kings-Bilbil/CerdasCanteen>
- Branch QA: `anggota-3`
- Branch gabungan: `master`

## Lisensi

Project ini dibuat untuk keperluan pembelajaran dan penilaian UAS.
