# Urutan Pengerjaan Anggota 3 (QA, Fitur Native & Dokumentasi)

Urutan ini mengikuti jadwal 7 hari di soal dan memperhitungkan ketergantungan pada kode Anggota 1 dan 2.

## Tahap 1 (Hari 1, Senin): Fondasi dan dokumen
1. **Tugas 1, analisis ekosistem** (`docs/`). Tulis 1-2 halaman: alasan Flutter dipilih untuk CerdasCanteen, perbandingan dengan Native (Kotlin) dan React Native, platform yang dipakai beserta alasan dan screenshot, serta arsitektur View-State-Service dan wireframe 3 layar. Wireframe dibuat bersama Anggota 2.
2. **Tugas 2c, `dart_basics/functions_null_safety.dart`**. Buat fungsi hitung total + diskon dengan parameter opsional `String? catatan`, jalankan, lalu screenshot output konsol. Ini tugas paling ringan, jadi kerjakan di hari pertama.

## Tahap 2 (Hari 2-4): Pengerjaan modul mandiri
3. **`lib/utils/queue_estimator.dart` dan test-nya (Tugas 13 TDD + Tugas 14)**. Modul ini berdiri sendiri, jadi bisa dikerjakan lebih awal. Tutorial TDD ada di bawah.
4. **Catat bug sejak awal**. Setiap ada error saat integrasi, langsung tulis di `docs/bug_log.md` dengan format gejala, penyebab, dan solusi. Jangan menunggu hari terakhir karena mudah lupa.
5. **Catat data analisis bisnis**. Ukur waktu antrean kantin secara manual (misalnya 10 orang) untuk bahan perbandingan sebelum vs sesudah aplikasi.

## Tahap 3 (Hari 5-6): Fitur native
6. **`lib/services/notification_service.dart` (Tugas 12)**. Inisialisasi plugin, minta permission notifikasi (Android 13+), dan buat fungsi `showOrderStatus(status)` untuk status Diproses → Siap Diambil. Berikan fungsi ini ke Anggota 1 untuk dipanggil dari alur checkout.
7. **`lib/services/device_service.dart` dan `lib/screens/profile_screen.dart`**. Pilih salah satu: `image_picker` (foto profil) atau `device_info_plus` (info perangkat). `device_info_plus` lebih mudah karena tidak perlu permission kamera, tetapi `image_picker` lebih menarik untuk demo. Tangani kasus permission ditolak.
8. **`lib/screens/qr_receipt_screen.dart` (Tugas 14)**. Gunakan package `qr_flutter` untuk menampilkan QR kode pesanan, dengan estimasi waktu dari `queue_estimator`.

## Tahap 4 (Hari 7, Minggu): Testing, dokumen final, dan video
9. **Unit test lainnya** (di `test/`). Tulis test total harga keranjang dan parsing JSON setelah kode Anggota 1 dan 2 selesai. Tulis juga test validasi form login/register.
10. **1 widget test**. Contoh: render `QrReceiptScreen` lalu cek bahwa teks estimasi dan widget QR muncul.
11. **Jalankan `flutter test`** dan simpan log atau screenshotnya.
12. **Tugas 13, analisis**. Lengkapi dokumentasi 2 bug, penilaian proses sistem (misalnya "apakah checkout dengan keranjang kosong ditolak?"), dan analisis waktu antrean beserta rekomendasi.
13. **Tugas 14, nilai bisnis**. Jelaskan manfaat QR struk dan estimasi antrean bagi kantin dan mahasiswa, serta keberlanjutannya (misalnya komisi atau iklan menu).
14. **Kompilasi laporan final** dari ketiga anggota, lalu **rekam dan edit video demo** 3-5 menit bersama tim.

---
```
Jalankan dan simpan log kegagalannya (ini bukti RED):
```
flutter test test/queue_estimator_test.dart > docs/tdd_red.log
```

**Langkah 2 (GREEN): isi implementasi seminimal mungkin:**
```dart
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  if (queueLength < 0 || itemCount < 0) {
    throw ArgumentError('Nilai tidak boleh negatif');
  }
  return (queueLength * 3) + (itemCount * 2);
}
```
Jalankan lagi dan simpan log lulusnya (bukti GREEN):
```
flutter test test/queue_estimator_test.dart > docs/tdd_green.log
```

**Langkah 3 (REFACTOR):** pindahkan angka 3 dan 2 menjadi konstanta atau parameter bernama, lalu jalankan test lagi untuk memastikan masih lulus.

**Untuk laporan:** screenshot atau lampirkan `tdd_red.log` dan `tdd_green.log`, lalu jelaskan satu paragraf tentang apa yang berubah di antara keduanya. Itu sudah memenuhi indikator "test dulu → gagal → implementasi → lulus".

Satu hal penting: urutan RED sebelum GREEN harus benar-benar dilakukan (log merah dibuat sebelum implementasi), karena itulah yang dinilai.