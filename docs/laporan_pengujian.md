# Laporan Pengujian CerdasCanteen — Anggota 3

## 1. Ringkasan

| Item | Hasil |
|---|---|
| Total test | **60 test** |
| Lulus | **60** |
| Gagal | **0** |
| `flutter analyze` | **No issues found** |
| Siklus TDD | 2 siklus (rumus, validasi) + 1 refactor |
| Unit test | 6 file (queue estimator, diagnostik estimator, total keranjang, JSON parsing, validators, services) |
| Widget test | 1 file (`form_widget_test.dart`, 5 test) |
| Log tersimpan | `docs/flutter_test.log`, `docs/flutter_analyze.log`, `docs/tdd/*.log`, `docs/contoh_output_gagal.log` |
| Dependency plugin | **tidak ada** (test berjalan tanpa plugin native) |
| Panduan membaca error | `docs/panduan_testing.md` |

## 2. Cara menjalankan

```powershell
# Semua test
flutter test | Tee-Object -FilePath docs/flutter_test.log

# Satu file (dipakai saat membuat bukti TDD)
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/01_red.log

# Analisis statis
flutter analyze | Tee-Object -FilePath docs/flutter_analyze.log
```

Di **FlutLab**, cukup buka tab *Test* atau jalankan `flutter test` di terminal —
tidak diperlukan emulator maupun `pubspec` dengan plugin native.

Cara membaca output test dan menelusuri penyebab kegagalan dijelaskan di
**`docs/panduan_testing.md`** (termasuk tabel gejala → penyebab → tindakan
G1–G14, dan bukti nyata di `docs/contoh_output_gagal.log`).

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

### 3.2 `test/queue_estimator_diagnostic_test.dart` — 8 test (diagnostik)

File terpisah supaya nama dan jumlah test di `queue_estimator_test.dart` tetap
sama dengan log TDD (`docs/tdd/01_red.log` … `05_refactor.log`). Tujuannya
**mendeteksi regresi diam-diam**, bukan mengulang test rumus.

| Kelompok | Test | Hasil |
|---|---|---|
| konstanta | `minutesPerQueue` bernilai 3 | LULUS |
| konstanta | `minutesPerItem` bernilai 2 | LULUS |
| sifat rumus | selisih antrean 3 orang = 3 × `minutesPerQueue` | LULUS |
| sifat rumus | selisih 4 item = 4 × `minutesPerItem` | LULUS |
| sifat rumus | 10 item tanpa antrean = 10 × `minutesPerItem` dan > 0 | LULUS |
| pesan error | pesan negatif memuat kata `'negatif'` | LULUS |
| pesan error | pesan pesanan kosong memuat `'minimal 1 item'` | LULUS |
| pesan error | input negatif dilaporkan negatif, bukan "pesanan kosong" | LULUS |

### 3.3 `test/order_total_test.dart` — 5 test (unit test: total harga keranjang)

| Test | Hasil |
|---|---|
| `OrderItem.subtotal` = harga × qty | LULUS |
| qty 1 sama dengan harga satuan | LULUS |
| `Order.totalPrice` menjumlahkan semua item | LULUS |
| keranjang kosong bernilai 0 dan ditandai kosong | LULUS |
| satu item tetap dihitung benar | LULUS |

### 3.4 `test/json_parsing_test.dart` — 10 test (unit test: parsing JSON)

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

### 3.5 `test/validators_test.dart` — 16 test (unit test: validasi form login/register)

Email (3 test), password (3), nama (3), konfirmasi password (3),
`isFormValid` (2), dan `CheckoutRules` (2) — termasuk uji
"keranjang kosong ditolak" untuk penilaian proses sistem Tugas 13.

### 3.6 `test/services_test.dart` — 11 test (unit test: service murni)

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

### 3.7 `test/form_widget_test.dart` — 5 widget test (syarat "1 widget test")

File ini **tidak mengimpor `lib/screens/**`**. Ia merakit `Form` +
`TextFormField` langsung di dalam test dan memakai `Validators.email` yang asli.
Dengan begitu widget test tetap bisa dijalankan di FlutLab meskipun layar
login/register belum dibuat Anggota 1.

| Widget test | Yang diperiksa | Hasil |
|---|---|---|
| email kosong memunculkan pesan wajib diisi | teks `'Email wajib diisi'` muncul, submit tidak lolos | LULUS |
| email salah format memunculkan pesan format | teks `'Format email tidak valid'` | LULUS |
| email valid meneruskan submit | teks `'Status: terkirim'` muncul | LULUS |
| pesan error hilang setelah input diperbaiki | error hilang, submit lolos | LULUS |
| teks hasil formatter bisa dirender | `'Rp35.000'` dan `'15 menit'` tampil | LULUS |

Widget test berbasis layar aplikasi (`QrReceiptScreen`, `ProfileScreen`) sengaja
**diparkir** di `docs/rencana_test/*.pending` karena layarnya adalah kode
implementasi sistem. Kontraknya didokumentasikan di `docs/Variabel.md` bagian 9.

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

## 5. Yang tidak tercakup automated test

Karena repo hanya berisi kode testing, bagian berikut **belum ada kodenya** dan
harus diimplementasikan tim:

| Fitur | Alasan | Cara verifikasi setelah dibuat |
|---|---|---|
| `NotificationService` (plugin) | Butuh platform channel Android/iOS | Jalankan app → Profil → tombol notifikasi |
| `DeviceService.load()` (jalur plugin) | Butuh plugin native | Buka layar Profil, cek info perangkat |
| `QrReceiptScreen` / tampilan QR | Bergantung layar sistem | Scan QR, cocokkan payload |
| `ProfileScreen` | Bergantung layar sistem | Buka layar Profil |

Bagian murni yang bisa diuji sudah dipisah dan diuji: `buildOrderStatusContent`,
`DeviceSummary.fromRaw`, `formatRupiah`, `formatEstimasiMenit`. Kontrak lengkap
untuk implementasi ada di `docs/Variabel.md`.

## 6. Catatan kegagalan yang pernah terjadi saat testing

| Kegagalan | Penyebab | Perbaikan |
|---|---|---|
| `avoid_print` (13 peringatan) | `dart_basics` memang mencetak ke konsol | `ignore_for_file: avoid_print` |
| `dangling_library_doc_comments` | doc library tanpa direktif | tambah `library;` |
| Log TDD terbaca biner | `Tee-Object` PS 5.1 menulis UTF-16 | dikonversi ke UTF-8 tanpa BOM |

Riwayat lengkap 8 bug (termasuk bug integrasi saat kode sistem masih ada) ada di
`docs/bug_log.md`.
