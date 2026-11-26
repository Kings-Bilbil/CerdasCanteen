# CerdasCanteen — Dokumentasi Proyek (Anggota 3)

Folder `docs/` ini berisi seluruh keluaran Anggota 3 (QA, Fitur Native &
Dokumentasi) sesuai `Tugas.md`.

> **Cakupan repo saat ini: hanya deliverable TESTING.** Sesuai instruksi,
> Anggota 3 tidak meninggalkan kode implementasi sistem (layar, service plugin,
> entry point demo) di repo. Yang ada adalah **kode yang diuji** (logika murni
> yang menjadi target test) + **seluruh test**. Daftar hal yang perlu dibuat
> ulang oleh tim beserta kontraknya ada di **`docs/Variabel.md`**.

## Peta dokumen

| File | Isi | Tugas |
|---|---|---|
| `Variabel.md` | **Daftar variabel/fungsi/teks yang dikunci test + yang perlu disesuaikan saat implementasi** | Lintas tugas |
| `analisis_ekosistem.md` | Alasan Flutter, perbandingan Native/React Native, platform, arsitektur View–State–Service, wireframe 3 layar | Tugas 1 |
| `tdd_laporan.md` | Laporan TDD lengkap: aturan bisnis, 2 siklus RED–GREEN, refactor, refleksi | Tugas 13 |
| `analisis_tugas13.md` | Penilaian proses sistem (13 skenario), data waktu antrean 10 responden, rekomendasi | Tugas 13 |
| `nilai_bisnis_tugas14.md` | Manfaat QR struk & estimasi antrean bagi mahasiswa & kantin, model keberlanjutan | Tugas 14 |
| `bug_log.md` | 8 bug dengan gejala → penyebab → solusi | Tugas 13 |
| `laporan_pengujian.md` | Rangkuman test, daftar test per file, batas cakupan automated test | Tugas 13/14 |
| `tdd/01_red.log` … `05_refactor.log` | Bukti log RED/GREEN/refactor | Tugas 13 |
| `flutter_test.log` | Log `flutter test` | Tugas 13 |
| `flutter_analyze.log` | Log `flutter analyze` | — |
| `dart_basics_output.log` | Output konsol `dart_basics/functions_null_safety.dart` | Tugas 2c |
| `rencana_test/*.pending` | Widget test layar yang diparkir sampai layarnya dibuat | Tugas 12/14 |

## Peta kode yang ada di repo

Hanya **kode target test** dan **test** yang dipertahankan.

| File | Isi |
|---|---|
| `dart_basics/functions_null_safety.dart` | Tugas 2c: fungsi total + diskon dengan `String? catatan` |
| `lib/utils/queue_estimator.dart` | Estimasi antrean `(antrean × 3) + (item × 2)` + validasi |
| `lib/utils/validators.dart` | Validasi form login/register + `CheckoutRules` |
| `lib/utils/formatters.dart` | Format rupiah & menit |
| `lib/models/order_item.dart` | Model item + `fromJson`/`toJson` |
| `lib/models/order.dart` | Model pesanan, `OrderStatus`, total keranjang |
| `lib/services/notification_service.dart` | **Hanya** `buildOrderStatusContent` + `NotificationContent` (bagian murni yang diuji) |
| `lib/services/device_service.dart` | **Hanya** `DeviceSummary.fromRaw` + `DeviceInfoEntry` (bagian murni yang diuji) |
| `test/queue_estimator_test.dart` | Test TDD (5) |
| `test/order_total_test.dart` | Test total keranjang (5) |
| `test/json_parsing_test.dart` | Test parsing JSON (10) |
| `test/validators_test.dart` | Test validasi form (15) |
| `test/services_test.dart` | Test service murni & formatter (11) |
| `test/form_widget_test.dart` | Widget test Form validasi (5) |

## Angka ringkas

- **51 test, semuanya lulus**; `flutter analyze` bersih.
- 6 commit berurutan membuktikan TDD: stub → RED → GREEN → RED → GREEN → refactor.
- 8 bug tercatat, semuanya selesai.
- 13 skenario penilaian proses sistem terdokumentasi.

## Yang masih perlu dilengkapi tim

1. **Screenshot** aplikasi berjalan (Android & web) → `docs/screenshots/`.
2. **Gambar wireframe** (Figma/sketsa) → `docs/wireframe/`.
3. **Tautan riwayat commit GitHub** untuk `tdd_laporan.md` bagian 5.
4. **Video demo 3–5 menit** bersama tim.
5. **Implementasi layar & service plugin** sesuai kontrak di `docs/Variabel.md`
   (bagian 4, 7, 9), lalu aktifkan kembali widget test di `docs/rencana_test/`.
