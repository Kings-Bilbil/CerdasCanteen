# CerdasCanteen — Dokumentasi Proyek (Anggota 3)

Folder `docs/` ini berisi seluruh keluaran Anggota 3 (QA, Fitur Native &
Dokumentasi) sesuai `Tugas.md`.

## Peta dokumen

| File | Isi | Tugas |
|---|---|---|
| `analisis_ekosistem.md` | Alasan Flutter, perbandingan Native/React Native, platform, arsitektur View–State–Service, wireframe 3 layar | Tugas 1 |
| `tdd_laporan.md` | Laporan TDD lengkap: aturan bisnis, 2 siklus RED–GREEN, refactor, refleksi | Tugas 13 |
| `analisis_tugas13.md` | Penilaian proses sistem (13 skenario), data waktu antrean 10 responden, rekomendasi | Tugas 13 |
| `nilai_bisnis_tugas14.md` | Manfaat QR struk & estimasi antrean bagi mahasiswa & kantin, model keberlanjutan | Tugas 14 |
| `bug_log.md` | 8 bug dengan gejala → penyebab → solusi | Tugas 13 |
| `laporan_pengujian.md` | Rangkuman 53 test, daftar test per file, batas cakupan automated test | Tugas 13/14 |
| `tdd/01_red.log` … `05_refactor.log` | Bukti log RED/GREEN/refactor | Tugas 13 |
| `flutter_test.log` | Log `flutter test` (53 test lulus) | Tugas 13 |
| `flutter_analyze.log` | Log `flutter analyze` (No issues found) | — |
| `dart_basics_output.log` | Output konsol `dart_basics/functions_null_safety.dart` | Tugas 2c |

## Peta kode yang dibuat Anggota 3

| File | Isi |
|---|---|
| `dart_basics/functions_null_safety.dart` | Tugas 2c: fungsi total + diskon dengan `String? catatan` |
| `lib/utils/queue_estimator.dart` | Estimasi antrean `(antrean × 3) + (item × 2)` + validasi |
| `lib/utils/validators.dart` | Validasi form login/register + `CheckoutRules` |
| `lib/utils/formatters.dart` | Format rupiah & menit |
| `lib/models/order_item.dart` | Model item + `fromJson`/`toJson` |
| `lib/models/order.dart` | Model pesanan, `OrderStatus`, total keranjang |
| `lib/services/notification_service.dart` | Notifikasi lokal + izin Android 13+ |
| `lib/services/device_service.dart` | `device_info_plus` + ringkasan perangkat |
| `lib/screens/profile_screen.dart` | Profil: info perangkat & tombol notifikasi |
| `lib/screens/qr_receipt_screen.dart` | Struk digital QR + estimasi |
| `lib/main_anggota3_demo.dart` | Entry point demo fitur Anggota 3 |
| `test/queue_estimator_test.dart` | Test TDD (5) |
| `test/order_total_test.dart` | Test total keranjang (5) |
| `test/json_parsing_test.dart` | Test parsing JSON (10) |
| `test/validators_test.dart` | Test validasi form (15) |
| `test/services_test.dart` | Test service & formatter (11) |
| `test/qr_receipt_screen_test.dart` | Widget test struk QR (4) |
| `test/profile_screen_test.dart` | Widget test halaman profil (3) |

## Angka ringkas

- 53 test, semuanya lulus; `flutter analyze` bersih.
- 6 commit berurutan membuktikan TDD: stub → RED → GREEN → RED → GREEN → refactor.
- 8 bug tercatat, semuanya selesai.
- 13 skenario penilaian proses sistem terdokumentasi.

## Yang masih perlu dilengkapi tim (bukan scope kode Anggota 3)

1. **Screenshot** aplikasi berjalan (Android & web) → simpan di `docs/screenshots/`.
   Placeholder sudah disebut di `analisis_ekosistem.md`.
2. **Gambar wireframe** (Figma/sketsa) → `docs/wireframe/`.
3. **Tautan riwayat commit GitHub** untuk `tdd_laporan.md` bagian 5.
4. **Video demo 3–5 menit** bersama tim.
5. **Integrasi**: memanggil `NotificationService.instance.showOrderStatus(...)`
   dari alur checkout Anggota 1, dan menavigasi ke `QrReceiptScreen` setelah
   checkout selesai.

## Integrasi cepat untuk Anggota 1

Setelah checkout berhasil:

```dart
import 'services/notification_service.dart';
import 'models/order.dart';

// Minta izin sekali (mis. saat aplikasi pertama dibuka atau saat checkout).
await NotificationService.instance.requestPermission();

// Status awal setelah checkout.
await NotificationService.instance.showOrderStatus(
  OrderStatus.diproses,
  orderId: order.id,
);

// Saat kantin menandai pesanan siap (estimasi opsional, dari queue_estimator).
final int estimasi = estimateWaitMinutes(
  queueLength: order.queueLength,
  itemCount: order.totalItems,
);
await NotificationService.instance.showOrderStatus(
  OrderStatus.siapDiambil,
  orderId: order.id,
  estimateMinutes: estimasi,
);
```

Menampilkan struk:

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => QrReceiptScreen(order: order),
  ),
);
```
