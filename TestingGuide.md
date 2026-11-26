# Daftar Lengkap Bukti TDD (Tugas 13)

Soal hanya meminta: *"tulis test dulu → gagal → implementasi → lulus (sertakan log)"*. Supaya aman dan kelihatan serius, siapkan semua bukti di bawah ini.

## A. Checklist yang harus ada

| No | Bukti | Lokasi |
|---|---|---|
| 1 | Deskripsi fitur dan aturan bisnis estimasi antrean | `docs/tdd_laporan.md` |
| 2 | Kerangka kosong (stub) yang belum berisi logika | `lib/utils/queue_estimator.dart` |
| 3 | File test yang ditulis sebelum implementasi | `test/queue_estimator_test.dart` |
| 4 | Log RED siklus 1 (gagal) | `docs/tdd/01_red.log` |
| 5 | Implementasi minimal | `lib/utils/queue_estimator.dart` |
| 6 | Log GREEN siklus 1 (lulus) | `docs/tdd/02_green.log` |
| 7 | Log RED siklus 2 (test validasi, gagal) | `docs/tdd/03_red.log` |
| 8 | Log GREEN siklus 2 (lulus) | `docs/tdd/04_green.log` |
| 9 | Hasil refactor, test tetap lulus | `docs/tdd/05_refactor.log` |
| 10 | Riwayat commit Git yang menunjukkan urutan test → kode | GitHub |
| 11 | Penjelasan satu paragraf per fase di laporan | `docs/tdd_laporan.md` |

Poin 10 penting karena rubrik menilai commit, dan commit itu membuktikan Anda tidak menulis kode dulu baru test.

## B. Langkah pengerjaan

### Langkah 0: Persiapan
1. Buka `pubspec.yaml`, lihat baris `name:` (misalnya `cerdascanteen`). Nama ini dipakai di `import`.
2. Buat folder `docs/tdd/`.
3. Pastikan `flutter test` bisa jalan (boleh dicoba dengan test kosong dulu).

**Catatan menyimpan log:**
- Di terminal Android Studio (PowerShell), pakai `| Tee-Object -FilePath docs/tdd/01_red.log` agar log tersimpan dan tetap tampil.
- Di Mac/Linux, pakai `| tee docs/tdd/01_red.log`.
- Kalau memakai FlutterLab.io dan tidak ada terminal, ambil screenshot hasil test (merah dan hijau) lalu simpan di `docs/tdd/`.

### Langkah 1: Stub kosong
`lib/utils/queue_estimator.dart`:
```dart
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  throw UnimplementedError();
}
```
Commit: `git commit -am "chore: stub queue estimator"`

### Langkah 2 (RED siklus 1): test rumus
Aturan bisnis: `waktu = (antrean × 3) + (item × 2)` menit.

`test/queue_estimator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cerdascanteen/utils/queue_estimator.dart';

void main() {
  group('estimateWaitMinutes - rumus', () {
    test('antrean kosong, 1 item = 2 menit', () {
      expect(estimateWaitMinutes(queueLength: 0, itemCount: 1), 2);
    });

    test('3 antrean, 2 item = 13 menit', () {
      expect(estimateWaitMinutes(queueLength: 3, itemCount: 2), 13);
    });
  });
}
```
Jalankan:
```
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/01_red.log
```
Hasil yang benar: **gagal** dengan `UnimplementedError`. Jangan lanjut sebelum log ini tersimpan.

Commit: `git add . && git commit -m "test(RED): rumus estimasi antrean"`

### Langkah 3 (GREEN siklus 1): implementasi minimal
```dart
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  return (queueLength * 3) + (itemCount * 2);
}
```
Jalankan:
```
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/02_green.log
```
Hasil: **All tests passed**.

Commit: `git commit -am "feat(GREEN): implementasi rumus estimasi"`

### Langkah 4 (RED siklus 2): test validasi
Tambahkan group baru di `main()` pada file test yang sama:
```dart
  group('estimateWaitMinutes - validasi', () {
    test('antrean negatif melempar ArgumentError', () {
      expect(() => estimateWaitMinutes(queueLength: -1, itemCount: 1),
          throwsArgumentError);
    });

    test('item negatif melempar ArgumentError', () {
      expect(() => estimateWaitMinutes(queueLength: 1, itemCount: -1),
          throwsArgumentError);
    });

    test('pesanan kosong (0 item) melempar ArgumentError', () {
      expect(() => estimateWaitMinutes(queueLength: 2, itemCount: 0),
          throwsArgumentError);
    });
  });
```
Catatan: test terakhir mengubah aturan, bahwa pesanan tanpa item tidak valid. Karena itu test pertama siklus 1 (`queueLength: 0, itemCount: 1`) tetap valid, tidak ada yang bentrok.

Jalankan:
```
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/03_red.log
```
Hasil: test rumus **lulus**, 3 test validasi **gagal** karena fungsi belum melempar error. Ini RED yang asli.

Commit: `git commit -am "test(RED): validasi input negatif dan pesanan kosong"`

### Langkah 5 (GREEN siklus 2)
```dart
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  if (queueLength < 0 || itemCount < 0) {
    throw ArgumentError('Nilai tidak boleh negatif');
  }
  if (itemCount == 0) {
    throw ArgumentError('Pesanan harus berisi minimal 1 item');
  }
  return (queueLength * 3) + (itemCount * 2);
}
```
Jalankan:
```
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/04_green.log
```
Commit: `git commit -am "feat(GREEN): validasi input"`

### Langkah 6 (REFACTOR)
Rapikan tanpa mengubah perilaku:
```dart
const int minutesPerQueue = 3;
const int minutesPerItem = 2;

int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  if (queueLength < 0 || itemCount < 0) {
    throw ArgumentError('Nilai tidak boleh negatif');
  }
  if (itemCount == 0) {
    throw ArgumentError('Pesanan harus berisi minimal 1 item');
  }
  return (queueLength * minutesPerQueue) + (itemCount * minutesPerItem);
}
```
Jalankan:
```
flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/05_refactor.log
```
Harus tetap hijau. Commit: `git commit -am "refactor: konstanta waktu"`

Setelah itu `git push`.

## C. Template laporan (`docs/tdd_laporan.md`)

```markdown
# Laporan TDD - Kalkulator Estimasi Waktu Antrean

## 1. Fitur dan aturan bisnis
Fitur menghitung estimasi waktu tunggu pesanan di CerdasCanteen.
Rumus: (jumlah antrean x 3 menit) + (jumlah item x 2 menit).
Pesanan tanpa item dan nilai negatif ditolak.

## 2. Siklus 1
- RED: test rumus ditulis saat fungsi masih UnimplementedError. Hasil: gagal. (lampirkan 01_red.log / screenshot)
- GREEN: implementasi satu baris rumus. Hasil: lulus. (02_green.log)

## 3. Siklus 2
- RED: test validasi ditambahkan. Hasil: 3 test gagal karena belum ada pengecekan. (03_red.log)
- GREEN: ditambahkan pengecekan input. Hasil: semua lulus. (04_green.log)

## 4. Refactor
Angka 3 dan 2 dipindah ke konstanta. Semua test tetap lulus. (05_refactor.log)

## 5. Bukti commit
Tautan riwayat commit GitHub: <isi>
Urutan: stub -> test RED -> GREEN -> test RED -> GREEN -> refactor.

## 6. Refleksi
Yang berubah antara RED dan GREEN: ... (jelaskan dengan kata sendiri)
Manfaat TDD pada fitur ini: ... (misalnya aturan "0 item ditolak" tertangkap sebelum kode jadi)
```

## D. Kesalahan yang sering terjadi
- **Menulis implementasi dulu lalu test.** Log RED jadi tidak asli dan commit akan menunjukkannya.
- **Log RED berisi error import**, bukan kegagalan test. Biasanya penyebabnya nama package salah. Perbaiki importnya dulu, baru jalankan ulang.
- **File log kosong** karena lupa `Tee-Object` atau salah path. Cek isinya sebelum lanjut.
- **Test lain di folder `test/` ikut gagal** karena kode anggota lain belum selesai. Jalankan hanya file ini dengan menyebut path-nya, seperti contoh di atas.

Test ini sekaligus bisa dihitung sebagai unit test pertama dari syarat "minimal 3 unit test". Dua lagi (total keranjang dan validasi form) dan satu widget test ditulis terpisah di Tahap 4.