# Bug Log — CerdasCanteen (Anggota 3)

Format tiap entri: **Gejala → Penyebab → Solusi**. Diisi sejak hari pertama
integrasi, bukan di akhir proyek.

Ringkasan: 8 bug tercatat, 8 selesai (✅), 0 terbuka. Dua bug pertama
(BUG-003 dan BUG-004) dipakai sebagai bahan analisis Tugas 13.

---

## BUG-001 — `UnimplementedError` saat test estimasi antrean

- **Gejala.** `flutter test test/queue_estimator_test.dart` gagal dengan
  `UnimplementedError` pada dua test rumus.
- **Penyebab.** Ini disengaja: stub `queue_estimator.dart` memang hanya
  `throw UnimplementedError()` sebagai fase RED TDD.
- **Solusi.** Diisi implementasi rumus pada fase GREEN. Log tersimpan di
  `docs/tdd/01_red.log` (gagal) dan `docs/tdd/02_green.log` (lulus).
- **Status.** ✅ Selesai (bukan bug produksi, melainkan bukti RED).

## BUG-002 — Test validasi merah padahal rumus sudah benar

- **Gejala.** Setelah rumus diimplementasi, tiga test validasi gagal dengan
  pesan `Expected: throws <Instance of 'ArgumentError'> / Actual: returned <-1>`.
- **Penyebab.** Fungsi belum memeriksa input negatif dan pesanan kosong.
- **Solusi.** Menambahkan dua pengecekan `ArgumentError`. Log:
  `docs/tdd/03_red.log` → `docs/tdd/04_green.log`.
- **Status.** ✅ Selesai.

## BUG-003 — Halaman profil gagal membaca info perangkat di web

- **Gejala.** Saat aplikasi dijalankan di Chrome untuk screenshot cepat,
  `DeviceService.load()` melempar `MissingPluginException` sehingga blok info
  perangkat tidak pernah selesai memuat (spinner berputar terus).
- **Penyebab.** `device_info_plus` memakai platform channel yang tidak
  tersedia pada target web dengan cara yang sama seperti mobile; selain itu
  pemanggilan `androidInfo` pada target non-Android memang tidak valid.
  Kode lama memanggil `androidInfo` tanpa memeriksa platform.
- **Solusi.**
  1. `DeviceService.load()` memeriksa `kIsWeb` lebih dulu dan memakai
     `webBrowserInfo` (nama browser + platform).
  2. Pemilihan platform memakai `defaultTargetPlatform` (Android / iOS / lainnya).
  3. Seluruh proses dibungkus `try/catch`; bila gagal, ditampilkan
     `DeviceSummary.fromRaw(model: 'Tidak diketahui')` agar halaman tetap
     bisa dipakai dan aplikasi tidak crash.
- **Bukti.** `DeviceSummary.fromRaw` diuji dengan data kosong pada
  `test/services_test.dart` (test "data kosong tidak menghasilkan entri kosong").
- **Status.** ✅ Selesai.

## BUG-004 — Izin notifikasi ditolak membuat tombol tidak bereaksi

- **Gejala.** Pada emulator Android 13, menekan tombol
  *Coba Notifikasi "Siap Diambil"* tanpa memberikan izin tidak menampilkan
  apa pun; pengguna mengira aplikasi hang.
- **Penyebab.** `requestNotificationsPermission()` mengembalikan `false`,
  tetapi kode lama tetap memanggil `show()`; notifikasi dibuang diam-diam oleh
  sistem sehingga tidak ada umpan balik ke pengguna.
- **Solusi.** `ProfileScreen._cobaNotifikasi()` memeriksa hasil izin. Bila
  `false`, aplikasi **tidak** memanggil `show()` dan menampilkan `AlertDialog`
  berisi penjelasan cara mengaktifkan izin di pengaturan perangkat. Bila `true`,
  notifikasi dikirim dan `SnackBar` menampilkan hasilnya.
- **Status.** ✅ Selesai.

## BUG-005 — Build Android gagal karena desugaring

- **Gejala.** `flutter build apk` gagal dengan pesan terkait
  `coreLibraryDesugaring` / API `java.time` setelah menambahkan
  `flutter_local_notifications`.
- **Penyebab.** Sejak versi 10, plugin ini mewajibkan *core library desugaring*
  di proyek Android, bahkan bila hanya memakai notifikasi instan.
- **Solusi.** Pada `android/app/build.gradle.kts`:
  `isCoreLibraryDesugaringEnabled = true` di blok `compileOptions`, dan
  `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` di
  blok `dependencies`.
- **Status.** ✅ Selesai.

## BUG-006 — `OrderItem` tidak dikenali pada `QrReceiptScreen`

- **Gejala.** `flutter test` gagal saat kompilasi:
  `Error: 'OrderItem' isn't a type` pada `lib/screens/qr_receipt_screen.dart`.
- **Penyebab.** File memakai tipe `OrderItem` di dalam `map()` tetapi hanya
  mengimpor `models/order.dart`; `order_item.dart` tidak diimpor (meski
  `order.dart` mengeksposnya secara tidak langsung saat runtime, import tetap
  dibutuhkan untuk resolusi tipe).
- **Solusi.** Menambahkan `import '../models/order_item.dart';`.
- **Status.** ✅ Selesai.

---

## BUG-007 — Widget test ProfileScreen "pumpAndSettle timed out"

- **Gejala.** `flutter test test/profile_screen_test.dart` gagal dengan
  `pumpAndSettle timed out` pada semua test. Mode kegagalan ini berbahaya karena
  terlihat seperti masalah animasi, padahal penyebabnya lain.
- **Penyebab.** Di lingkungan `flutter test`, plugin native
  `device_info_plus` tidak tersedia sehingga `MethodChannel` tidak pernah
  menjawab. `Future` pada `FutureBuilder` tidak pernah selesai, spinner
  `CircularProgressIndicator` terus beranimasi, dan `pumpAndSettle` menunggu
  sampai timeout.
- **Solusi.** `DeviceService` diberi jalur injeksi `DeviceSummaryLoader` yang
  opsional. Bila diisi (khusus test), loader itu dipakai menggantikan plugin
  native. Test `profile_screen_test.dart` memakai loader palsu, sehingga Future
  selesai dan UI bisa diverifikasi — termasuk kasus loader gagal (fallback
  "Tidak diketahui").
- **Catatan desain.** Pola ini sekaligus perbaikan arsitektur: View tidak lagi
  bergantung langsung pada plugin, melainkan pada service yang bisa diganti.
- **Status.** ✅ Selesai.

---

## BUG-008 — Log TDD tidak bisa dibuka (dianggap file biner)

- **Gejala.** `docs/tdd/01_red.log` dan log lain gagal dibuka di editor;
  muncul pesan "Cannot read binary file". Saat di-commit, diff-nya juga tidak
  tampil.
- **Penyebab.** `Tee-Object` pada PowerShell 5.1 menulis file keluaran dengan
  encoding **UTF-16 LE + BOM**. Banyak editor dan GitHub menganggapnya biner.
- **Solusi.** Semua file log dikonversi ke **UTF-8 tanpa BOM**:

```powershell
$raw = Get-Content docs/tdd/01_red.log -Encoding Unicode -Raw
[System.IO.File]::WriteAllText(
  (Resolve-Path docs/tdd/01_red.log), $raw,
  (New-Object System.Text.UTF8Encoding $false))
```

  Isi log tidak diubah — hanya encoding-nya, sehingga bukti RED/GREEN tetap asli.
- **Pencegahan.** Untuk run berikutnya, tambahkan `| Out-File -Encoding utf8`
  atau pakai PowerShell 7 (`Tee-Object` di sana sudah UTF-8).
- **Status.** ✅ Selesai.

---

## Bug yang ditemukan saat verifikasi akhir

| Bug | Uji | Hasil |
|---|---|---|
| Interpolasi `'ID:$order.id'` menghasilkan `ID:Instance of 'Order'.id` | `test/qr_receipt_screen_test.dart` — "data QR memuat ringkasan pesanan" | Tertangkap test, diperbaiki menjadi `'ID:${order.id}'` |

Bug terakhir ini layak dicatat sebagai bukti nilai test: kesalahan yang sangat
mudah lolos dari mata saat membaca kode, tetapi langsung terlihat karena test
memeriksa isi payload QR.
