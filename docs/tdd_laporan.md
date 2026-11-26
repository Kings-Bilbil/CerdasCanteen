# Laporan TDD — Kalkulator Estimasi Waktu Antrean

Dokumen ini melengkapi checklist bukti TDD pada `TestingGuide.md` bagian A.

## 1. Fitur dan aturan bisnis

Fitur menghitung estimasi waktu tunggu pesanan di CerdasCanteen. Nilainya
dipakai oleh layar struk digital (QR) dan notifikasi "Siap Diambil" pada
implementasi sistem; modul ini sendiri berdiri sendiri sehingga bisa diuji
tanpa layar (lihat `docs/Variabel.md`).

Rumus:

```
waktu_tunggu_menit = (jumlah_antrean × 3 menit) + (jumlah_item × 2 menit)
```

Aturan bisnis tambahan:

1. `queueLength` dan `itemCount` tidak boleh negatif → `ArgumentError`.
2. Pesanan tanpa item (`itemCount == 0`) ditolak → `ArgumentError`.
   Alasannya: pesanan kosong tidak mungkin disajikan kantin dan tidak boleh
   menghasilkan estimasi "2 menit" yang menyesatkan.

Contoh: antrean 3 orang, 2 item → (3 × 3) + (2 × 2) = **13 menit**.

## 2. Daftar bukti

> **Catatan path.** Log di `docs/tdd/` adalah keluaran **asli** saat proses
> TDD berjalan, ketika kode masih berada di `lib/utils/queue_estimator.dart`.
> Setelah repo dibatasi menjadi deliverable testing dan kode dipindah ke
> `test/fixtures/` agar tidak bertabrakan dengan kode Anggota 1 & 2, log
> **sengaja tidak diubah** — itu bukti historis. Path yang terlihat di log
> (`package:tubes_perak/utils/queue_estimator.dart`) merujuk lokasi lama;
> lokasi sekarang: `test/fixtures/utils/queue_estimator.dart`.

| No | Bukti | Lokasi | Status |
|---|---|---|---|
| 1 | Deskripsi fitur & aturan bisnis | `docs/tdd_laporan.md` (dokumen ini) | ✅ |
| 2 | Stub kosong tanpa logika | riwayat commit `chore: stub queue estimator` | ✅ |
| 3 | File test ditulis sebelum implementasi | `test/queue_estimator_test.dart` | ✅ |
| 4 | Log RED siklus 1 | `docs/tdd/01_red.log` | ✅ |
| 5 | Implementasi minimal | `test/fixtures/utils/queue_estimator.dart` | ✅ |
| 6 | Log GREEN siklus 1 | `docs/tdd/02_green.log` | ✅ |
| 7 | Log RED siklus 2 (validasi) | `docs/tdd/03_red.log` | ✅ |
| 8 | Log GREEN siklus 2 | `docs/tdd/04_green.log` | ✅ |
| 9 | Log refactor (tetap hijau) | `docs/tdd/05_refactor.log` | ✅ |
| 10 | Riwayat commit Git | lihat bagian 5 | ✅ |
| 11 | Penjelasan tiap fase | bagian 3–6 | ✅ |

## 3. Siklus 1 — rumus

- **RED.** `test/fixtures/utils/queue_estimator.dart` masih stub
  `throw UnimplementedError();`. Test rumus ditulis lebih dulu, lalu dijalankan.
  Hasil: **2 test gagal** dengan `UnimplementedError`
  (`01_red.log`). Ini kegagalan test yang sah, bukan kegagalan import.
- **GREEN.** Implementasi minimal satu baris:
  `return (queueLength * 3) + (itemCount * 2);`
  Hasil: **All tests passed!** (`02_green.log`).

Commit: `test(RED): rumus estimasi antrean` → `feat(GREEN): implementasi rumus estimasi`.

## 4. Siklus 2 — validasi

- **RED.** Group `estimateWaitMinutes - validasi` ditambahkan (3 test: antrean
  negatif, item negatif, pesanan 0 item). Dijalankan sebelum ada pengecekan.
  Hasil: 2 test rumus **lulus**, 3 test validasi **gagal** karena fungsi
  mengembalikan angka (mis. `returned <-1>`) alih-alih melempar `ArgumentError`
  (`03_red.log`). Ini RED yang asli: kegagalan berasal dari perilaku kode,
  bukan dari error kompilasi.
- **GREEN.** Ditambahkan dua blok pengecekan:

```dart
if (queueLength < 0 || itemCount < 0) {
  throw ArgumentError('Nilai tidak boleh negatif');
}
if (itemCount == 0) {
  throw ArgumentError('Pesanan harus berisi minimal 1 item');
}
```

Hasil: **5 test lulus** (`04_green.log`).

Commit: `test(RED): validasi input negatif dan pesanan kosong` → `feat(GREEN): validasi input`.

## 5. Refactor

Angka `3` dan `2` dipindah menjadi konstanta bernama `minutesPerQueue` dan
`minutesPerItem`, plus perbaikan dokumentasi (`library;` untuk menghilangkan
peringatan *dangling library doc comment*). Perilaku tidak berubah.
Hasil: **5 test tetap lulus** (`05_refactor.log`).

Commit: `refactor: konstanta waktu`.

Urutan commit pada branch `QA`:

```
chore: stub queue estimator
test(RED): rumus estimasi antrean
feat(GREEN): implementasi rumus estimasi
test(RED): validasi input negatif dan pesanan kosong
feat(GREEN): validasi input
refactor: konstanta waktu
```

Urutan ini membuktikan test ditulis **sebelum** implementasi: commit test RED
selalu mendahului commit kode GREEN.

## 6. Refleksi

**Apa yang berubah antara RED dan GREEN.** Pada siklus 1, file implementasi
hanya berisi `throw UnimplementedError()`, sehingga ketika test dijalankan
kedua assertion langsung gagal dengan `UnimplementedError` — test sudah
menyatakan harapan (2 menit dan 13 menit) tetapi belum ada kode yang bisa
memenuhinya. Setelah implementasi satu baris rumus ditambahkan, perintah
`flutter test` yang sama berubah menjadi `All tests passed!`. Pada siklus 2,
perubahan yang terjadi lebih halus: test rumus tetap hijau, tetapi tiga test
validasi merah karena fungsi masih "suka rela" menghitung nilai negatif
(`returned <-1>`) dan pesanan kosong (`returned <6>`); setelah dua blok
`if` pengecekan ditambahkan, ketiganya berubah menjadi hijau tanpa satu pun test
lama ikut rusak.

**Manfaat TDD pada fitur ini.** Aturan "pesanan 0 item ditolak" tertangkap
sebelum kode jadi. Tanpa TDD, kasus ini kemungkinan besar baru ditemukan saat
demo, ketika layar struk menampilkan estimasi "2 menit" untuk keranjang kosong.
Selain itu, karena rumus dan validasi sudah dikunci oleh test, refactor
(konstanta bernama) bisa dilakukan dengan percaya diri — kalau refactor salah,
test langsung memberi tahu. Test ini juga menjadi unit test pertama dari syarat
"minimal 3 unit test".

## 7. Catatan teknis

- Perintah penyimpanan log di PowerShell:
  `flutter test test/queue_estimator_test.dart | Tee-Object -FilePath docs/tdd/01_red.log`
- Test dijalankan **per file** agar kegagalan test anggota lain tidak
  mengaburkan bukti RED/GREEN modul ini.
- Exit code RED = 1, GREEN = 0. Nilai exit code ini tercatat pada log
  (baris `===EXITCODE===` pada saat eksekusi).
- File log awalnya tersimpan sebagai UTF-16 (default `Tee-Object` pada
  PowerShell 5.1) sehingga terbaca sebagai biner di editor/GitHub. Log telah
  dikonversi ke **UTF-8 tanpa BOM** agar bisa dibuka langsung.
