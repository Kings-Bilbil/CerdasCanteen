# Laporan Pengujian CerdasCanteen — Anggota 3

## 1. Ringkasan

| Item | Hasil |
|---|---|
| Total test | **53 test** |
| Lulus | **53** |
| Gagal | **0** |
| `flutter analyze` | **No issues found** |
| Siklus TDD | 2 siklus (rumus, validasi) + 1 refactor |
| Unit test | 5 file (queue estimator, total keranjang, JSON parsing, validators, services) |
| Widget test | 2 file (`qr_receipt_screen_test.dart` 4 test, `profile_screen_test.dart` 3 test) |
| Log tersimpan | `docs/flutter_test.log`, `docs/flutter_analyze.log`, `docs/tdd/*.log` |

## 2. Cara menjalankan

```powershell
# Semua test
flutter test | Tee-Object -FilePath docs/flutter_test.log

# Satu file (dipakai saat membuat bukti TDD)
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/01_red.log

# Analisis statis
flutter analyze | Tee-Object -FilePath docs/flutter_analyze.log

# Demo fitur native (tanpa bentrok dengan main.dart milik Anggota 1)
flutter run -t lib/main_anggota3_demo.dart
```

## 3. Daftar test per file

### 3.1 `test/queue_estimator_test.dart` — 5 test (Tugas 13, TDD)

| Test | Jenis | Hasil |
|---|---|---|
| antrean kosong, 1 item = 2 menit | rumus | LULUS |
| 3 antrean, 2 item = 13 menit | rumus | LULUS |
| antrean negatif melempar ArgumentError | validasi | LULUS |
| item negatif melempar ArgumentError | validasi | LULUS |
| pesanan kosong (0 item) melempar ArgumentError | validasi | LULUS |

File ini ditulis **sebelum** implementasi; bukti RED/GREEN ada di `docs/tdd/`.

### 3.2 `test/order_total_test.dart` — 5 test (unit test: total harga keranjang)

| Test | Hasil |
|---|---|
| `OrderItem.subtotal` = harga × qty | LULUS |
| qty 1 sama dengan harga satuan | LULUS |
| `Order.totalPrice` menjumlahkan semua item | LULUS |
| keranjang kosong bernilai 0 dan ditandai kosong | LULUS |
| satu item tetap dihitung benar | LULUS |

### 3.3 `test/json_parsing_test.dart` — 10 test (unit test: parsing JSON)

| Test | Hasil |
|---|---|
| parsing JSON normal | LULUS |
| parsing dari string JSON (angka sebagai teks) | LULUS |
| mendukung alias field bahasa Inggris | LULUS |
| nama kosong melempar FormatException | LULUS |
| harga negatif melempar FormatException | LULUS |
| qty 0 melempar FormatException | LULUS |
| parsing order lengkap (2 item, status, antrean) | LULUS |
| status tidak dikenal jatuh ke Diproses | LULUS |
| items bukan array melempar FormatException | LULUS |
| round-trip toJson → fromJson konsisten | LULUS |

### 3.4 `test/validators_test.dart` — 15 test (unit test: validasi form login/register)

Email (3 test), password (3), nama (3), konfirmasi password (3),
`isFormValid` (2), dan `CheckoutRules` (2) — termasuk uji
"keranjang kosong ditolak" untuk penilaian proses sistem Tugas 13.

### 3.5 `test/services_test.dart` — 11 test (unit test: service)

| Kelompok | Test | Hasil |
|---|---|---|
| `buildOrderStatusContent` Diproses | judul memuat ID pesanan | LULUS |
| `buildOrderStatusContent` Siap Diambil | menyertakan estimasi bila diberikan | LULUS |
| `buildOrderStatusContent` Siap Diambil | tetap valid tanpa estimasi | LULUS |
| `buildOrderStatusContent` Selesai | judul & isi sesuai | LULUS |
| `DeviceSummary.fromRaw` | menyusun entri Android lengkap | LULUS |
| `DeviceSummary.fromRaw` | data kosong tidak menghasilkan entri kosong | LULUS |
| `DeviceSummary.fromRaw` | token panjang dipotong | LULUS |
| `Formatters` | formatRupiah memberi pemisah ribuan | LULUS |
| `Formatters` | formatEstimasiMenit < 1 jam | LULUS |
| `Formatters` | formatEstimasiMenit > 1 jam | LULUS |

### 3.6 `test/qr_receipt_screen_test.dart` — 4 widget test (Tugas 14)

| Widget test | Yang diperiksa | Hasil |
|---|---|---|
| menampilkan widget QR, estimasi, dan total | `QrImageView` muncul, teks "15 menit", total Rp35.000, subtotal, nama item, status, jumlah antrean, instruksi ke kasir | LULUS |
| estimasi manual mengalahkan hitung otomatis | `estimateMinutes: 25` mengalahkan hasil `estimateWaitMinutes` | LULUS |
| data QR memuat ringkasan pesanan | payload berisi `CERDASCANTEEN`, `ID:CC-2024`, `TOTAL:35000`, `EST:15` | LULUS |
| status Siap Diambil tampil sebagai chip | chip status + estimasi 2 menit (antrean 0, 1 item) | LULUS |

### 3.7 `test/profile_screen_test.dart` — 3 widget test (Tugas 12)

| Widget test | Yang diperiksa | Hasil |
|---|---|---|
| menampilkan identitas mahasiswa dan info perangkat | spinner saat loading, nama & NIM, baris "Perangkat"/"Versi Android" dari `DeviceSummary`, tombol notifikasi | LULUS |
| tombol refresh memuat ulang info perangkat | tap ikon refresh memicu pemuatan ulang dan data kembali tampil | LULUS |
| loader gagal tetap menampilkan fallback, bukan error | error dari service ditangkap; UI menampilkan "Tidak diketahui" | LULUS |

Widget test ini memakai `DeviceService(loader: ...)` (dependency injection)
sehingga tidak butuh plugin native saat test.

## 4. Bukti TDD (ringkas)

| Fase | Log | Isi |
|---|---|---|
| Stub | commit `chore: stub queue estimator` | `throw UnimplementedError()` |
| RED siklus 1 | `docs/tdd/01_red.log` | 2 test gagal (`UnimplementedError`) |
| GREEN siklus 1 | `docs/tdd/02_green.log` | All tests passed |
| RED siklus 2 | `docs/tdd/03_red.log` | 2 lulus, 3 gagal (`returned <-1>`) |
| GREEN siklus 2 | `docs/tdd/04_green.log` | All tests passed (5 test) |
| REFACTOR | `docs/tdd/05_refactor.log` | All tests passed, konstanta bernama |

Penjelasan lengkap: `docs/tdd_laporan.md`.

## 5. Yang tidak tercakup automated test (dan cara diverifikasinya)

| Fitur | Alasan | Verifikasi manual |
|---|---|---|
| `NotificationService.init()` / `show()` / `requestPermission()` | Butuh platform channel Android/iOS | `flutter run -t lib/main_anggota3_demo.dart` → Profil → tombol notifikasi |
| `DeviceService.load()` (jalur plugin nyata) | Butuh plugin native | Buka layar Profil, cek daftar info perangkat + tombol refresh |
| Tampilan nyata `QrImageView` (hasil scan) | Perlu kamera perangkat | Scan QR dengan HP lain, cocokkan payload |

Logika yang bisa dipisahkan (pembuatan judul/isi notifikasi, ringkasan
perangkat, format rupiah/menit) sudah dipisah agar tetap bisa diuji tanpa
perangkat — lihat `buildOrderStatusContent`, `DeviceSummary.fromRaw`, dan
`lib/utils/formatters.dart`. Halaman Profil juga menerima `DeviceService`
palsu lewat konstruktor, sehingga alur UI-nya bisa diuji.

## 6. Catatan kegagalan yang pernah terjadi saat testing

| Kegagalan | Penyebab | Perbaikan |
|---|---|---|
| `'OrderItem' isn't a type` | import tidak lengkap di `qr_receipt_screen.dart` | tambah `import '../models/order_item.dart'` |
| `getter 'data' isn't defined for QrImageView` | `QrImageView` tidak mengekspos `data` sebagai field publik | test memeriksa `QrReceiptScreen.qrData` + keberadaan `QrImageView` |
| payload berisi `ID:Instance of 'Order'.id` | interpolasi `'$order.id'` | diubah menjadi `'${order.id}'` |
| `pumpAndSettle timed out` pada ProfileScreen | plugin native tidak ada di lingkungan test → Future tidak pernah selesai, spinner beranimasi terus | tambah `DeviceServiceLoader` untuk injeksi; test memakai loader palsu |
| `avoid_print` (13 peringatan) | `dart_basics` memang mencetak ke konsol | `ignore_for_file: avoid_print` |
| `dangling_library_doc_comments` | doc library tanpa direktif | tambah `library;` |
