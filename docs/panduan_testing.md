# Panduan Testing — Membaca Hasil & Menelusuri Penyebab Error

Dokumen ini untuk **tester** (dan anggota tim lain) yang menjalankan test
CerdasCanteen. Isinya: cara menjalankan, cara membaca output, dan **tabel
pemetaan gejala → penyebab → tindakan**.

Prinsip yang dipakai di repo ini: **setiap kegagalan test harus menjelaskan
dirinya sendiri**. Semua `expect()` diberi `reason:` berisi input yang dipakai,
nilai yang diharapkan, dan kemungkinan penyebabnya. Jadi tester tidak perlu
menebak.

---

## 1. Cara menjalankan

```powershell
# semua test
flutter test

# satu file saja (lebih cepat saat menelusuri error)
flutter test test/queue_estimator_test.dart

# satu test tertentu berdasarkan nama
flutter test --plain-name "pesanan kosong"

# simpan log sekaligus
flutter test | Tee-Object -FilePath docs/flutter_test.log
```

Di **FlutLab**: buka tab **Test**, atau jalankan `flutter test` di terminal.
Repo ini tidak memakai plugin native (tidak ada `device_info_plus`,
`flutter_local_notifications`, `qr_flutter`), jadi `flutter test` berjalan tanpa
emulator dan tanpa `flutter build`.

Sebelum membaca hasil test, sebaiknya jalankan juga:

```powershell
flutter analyze
```

`flutter analyze` menangkap masalah yang **tidak** terlihat oleh test
(import salah, tipe tidak cocok, method belum ada). Kalau `flutter analyze`
merah, perbaiki itu dulu — kalau tidak, test bisa gagal karena file test-nya
sendiri tidak bisa dikompilasi (lihat §5, gejala G1).

---

## 2. Membaca satu baris output

Contoh baris normal saat semua lolos:

```
00:02 +60: All tests passed!
```

Artinya: 60 test, 0 gagal (`+60` = jumlah lulus).

Contoh per test:

```
00:00 +5 -1: D:/Project/perak/test/validators_test.dart: password kurang dari 8 karakter ditolak
```

| Bagian | Arti |
|---|---|
| `00:00` | waktu berjalan |
| `+5` | 5 test sudah lulus |
| `-1` | 1 test **gagal** |
| `test/...dart: <nama>` | file + nama test yang sedang dijalankan |

Jadi rumus membacanya: **`+` lulus, `-` gagal**. Angka `-` adalah jumlah
kegagalan, bukan nomor test.

Baris terakhir menentukan kesimpulan:

| Baris terakhir | Arti |
|---|---|
| `All tests passed!` | semua lulus, exit code `0` |
| `Some tests failed.` | ada kegagalan, exit code `1` |

---

## 3. Membaca blok kegagalan (bagian terpenting)

Saat gagal, test mencetak blok seperti ini (nyata, dari
`docs/contoh_output_gagal.log`):

```
00:00 +0 -1: CONTOH GAGAL - estimasi salah [E]
  Expected: <15>
    Actual: <13>
  INPUT queueLength=3, itemCount=2 -> HARAP 15 menit (sengaja salah untuk contoh).
  Bila gagal: cek minutesPerItem atau rumus di lib/utils/queue_estimator.dart.
  package:matcher ...
  test\_contoh_gagal_sementara_test.dart 8:5  main.<fn>
```

Cara membacanya, berurutan:

1. **Nama test** (`CONTOH GAGAL - estimasi salah`) — fitur apa yang bermasalah.
2. **`Expected` vs `Actual`** — nilai yang diharapkan test vs nilai yang
   benar-benar dikembalikan kode.
   - `Expected: <15>` `Actual: <13>` → kode mengembalikan 13, seharusnya 15.
3. **Baris `reason`** (kalimat panjang di bawah `Actual`) — ditulis oleh pembuat
   test. Isinya: input, harapan, dan **kemungkinan penyebab**. Ini yang
   menggantikan pekerjaan menebak.
4. **Lokasi** (`test\...dart 8:5 main.<fn>`) — file test dan baris `expect` yang
   gagal. Berguna untuk membuka kembali test-nya.
5. Kalau kegagalan berasal dari dalam kode produksi, ada juga baris
   `package:tubes_perak/utils/...` — itu lokasi kode yang perlu diperbaiki.

> **Tips:** kalau `reason` kosong pada suatu test, itu berarti test tersebut
> belum memenuhi standar repo ini. Tambahkan `reason:`-nya.

---

## 4. Tiga bentuk kegagalan yang berbeda

Tester perlu membedakan ketiganya karena tindakannya berbeda total.

### 4.1 Salah nilai (logika/rumus salah)

```
Expected: <13>
  Actual: <15>
```

Penyebab: rumus atau konstanta berubah. Cek `lib/utils/queue_estimator.dart`
(`minutesPerQueue`, `minutesPerItem`).

### 4.2 Fungsi tidak melempar error padahal seharusnya

Ini bentuk khas kegagalan **validasi**. Bentuknya agak berbeda:

```
Expected: throws <Instance of 'ArgumentError'>
  Actual: <Closure: () => int>
   Which: returned <-1>
```

Bacaannya: "test mengharapkan fungsi melempar `ArgumentError`, tetapi fungsi
**mengembalikan nilai** `-1`". Artinya pengecekan input **belum ada** di kode.
Ini persis yang terlihat di `docs/tdd/03_red.log`.

Tindakan: tambahkan pengecekan (`if (...) throw ArgumentError(...)`), bukan
mengubah test.

### 4.3 Fungsi belum diimplementasikan (fase RED, bukan bug)

```
UnimplementedError
package:tubes_perak/utils/queue_estimator.dart 7:3
```

Ini **normal dan disengaja** pada fase RED TDD (`docs/tdd/01_red.log`). Isinya
`throw UnimplementedError()` sebagai stub. Bukan bug; jangan "diperbaiki" dengan
menghapus test. Lanjutkan ke fase GREEN.

---

## 5. Tabel gejala → penyebab → tindakan

Tabel ini adalah rujukan utama saat membaca error.

| Kode | Gejala di output | Penyebab paling mungkin | Tindakan |
|---|---|---|---|
| **G1** | `Error: Couldn't resolve the package '...'` atau `Target of URI doesn't exist` | nama package di `import` salah | Package harus **`tubes_perak`**. Contoh benar: `import 'package:tubes_perak/utils/queue_estimator.dart';` |
| **G2** | `The method 'X' isn't defined for the type 'Y'` | nama fungsi/field berubah di kode produksi | Samakan dengan kontrak di `docs/Variabel.md`, atau perbaiki test bila memang nama baru disepakati |
| **G3** | `Too few positional arguments: 2 required, 1 given` | lupa matcher pada `expect`, mis. `expect(a < b, reason: ...)` | tambahkan matcher: `expect(a < b, isTrue, reason: ...)` |
| **G4** | `Expected: <13>` `Actual: <15>` | rumus/konstanta berubah | cek `minutesPerQueue` / `minutesPerItem` di `lib/utils/queue_estimator.dart` |
| **G5** | `Expected: throws ...` + `Which: returned <n>` | validasi input hilang | tambahkan pengecekan negatif / `itemCount == 0` |
| **G6** | `Expected: throws ...` + `Which: threw <pesan lain>` | urutan pengecekan salah (mis. cek "0 item" sebelum cek negatif) | cek negatif **lebih dulu**, baru cek pesanan kosong. Diuji di `queue_estimator_diagnostic_test.dart` |
| **G7** | `UnimplementedError` | masih stub fase RED | bukan bug — lanjut implementasi (GREEN) |
| **G8** | `FormatException: Nama menu wajib diisi` dsb. | data uji atau validasi model tidak sesuai | pesan persis terdaftar di `docs/Variabel.md` §2 |
| **G9** | `Bad state: No element` pada `find.byKey(...)` | widget dengan key tersebut tidak ada / belum di-render | cek `Key('email-field')`, `Key('submit-button')`; pastikan `pumpWidget` sudah dipanggil |
| **G10** | `Expected: exactly one matching node ... Actual: _TextWidgetFinder:<zero widgets with text "X">` | teks di UI berubah atau belum muncul | cek teks persis di kode; ingat pesan error validasi harus sama karakter-per-karakter |
| **G11** | `pumpAndSettle timed out` | ada future/animasi yang tidak pernah selesai (biasanya platform channel plugin) | repo ini menghindarinya dengan injeksi `DeviceSummaryLoader`; lihat `docs/Variabel.md` §7 |
| **G12** | `The name 'X' is being used for a const` / `prefer_const` | pelanggaran lint | jalankan `flutter analyze`, ikuti saran perbaikannya |
| **G13** | hanya **beberapa** test gagal, sisanya lulus | perubahan kode memengaruhi satu aturan saja | jalankan hanya file terkait: `flutter test test/<file>.dart` |
| **G14** | `Failed to load ... .dart` saat `flutter test` di FlutLab | file bukan `.dart` ikut terbaca, atau `pubspec` butuh `flutter pub get` | pastikan file non-test ber-ekstensi `.pending` (di `docs/rencana_test/`), lalu jalankan `flutter pub get` |

---

## 6. Cakupan test: kenapa ada 60 test

| File | Jumlah | Yang dijaga |
|---|---|---|
| `test/queue_estimator_test.dart` | 5 | rumus + validasi (bukti TDD, jangan diubah tanpa memperbarui `docs/tdd/*.log`) |
| `test/queue_estimator_diagnostic_test.dart` | 8 | **diagnostik**: konstanta, sifat linear rumus, keterlacakan pesan error |
| `test/order_total_test.dart` | 5 | total keranjang |
| `test/json_parsing_test.dart` | 10 | parsing JSON + alias + kasus gagal |
| `test/validators_test.dart` | 16 | validasi form login/register + aturan checkout |
| `test/services_test.dart` | 11 | `buildOrderStatusContent`, `DeviceSummary.fromRaw`, formatter |
| `test/form_widget_test.dart` | 5 | widget test `Form` + `TextFormField` |
| **Total** | **60** | |

### Kenapa ada file "diagnostic" terpisah

Tanpa file ini, test hanya berhenti pada "lulus/gagal". Dengan file ini, kalau
seseorang diam-diam mengubah `minutesPerQueue` dari `3` menjadi `4` **dan**
sekaligus mengubah test rumusnya, regresi tetap tertangkap karena:

- konstanta diuji langsung (`minutesPerQueue == 3`), dan
- sifat rumus diuji tanpa terikat angka: selisih `(4,1) - (1,1)` harus sama
  dengan `3 × minutesPerQueue`, jadi perubahan konstanta tetap konsisten secara
  matematis tetapi **tidak lolos** uji konstanta.

File ini juga menguji **pesan error bisa ditelusuri** (mengandung kata
`'negatif'` / `'minimal 1 item'`) dan **urutan pengecekan** (input negatif
dilaporkan sebagai negatif, bukan sebagai pesanan kosong). Jadi tester bisa
langsung tahu aturan mana yang rusak.

---

## 7. Prosedur saat menemukan kegagalan

1. Jalankan `flutter test` dan catat **nama test** yang gagal.
2. Baca baris `reason` di bawah `Expected`/`Actual` — biasanya sudah menyebut
   penyebab dan file yang perlu dicek.
3. Cocokkan gejalanya dengan tabel §5 untuk menentukan kode G1–G14.
4. Jalankan hanya file terkait: `flutter test test/<file>.dart`.
5. Perbaiki **kode produksi**, bukan test — kecuali memang aturan bisnisnya
   berubah dan disepakati tim (kalau begitu, perbarui juga `docs/Variabel.md`
   dan `docs/tdd_laporan.md`).
6. Jalankan ulang semua test + `flutter analyze`.
7. Catat di `docs/bug_log.md`: gejala → penyebab → solusi.

---

## 8. Kalau aturan bisnis memang berubah

Test mengunci perilaku. Kalau keputusan tim berubah (misalnya tarif antrean
menjadi 4 menit per orang), lakukan berurutan:

1. Ubah **test** (fase RED baru) dan simpan log-nya.
2. Ubah **implementasi** sampai hijau (GREEN), simpan log.
3. Perbarui `docs/Variabel.md` supaya kontrak tetap satu sumber kebenaran.
4. Perbarui `docs/tdd_laporan.md` bagian refleksi.

Jangan mengubah test hanya supaya hijau tanpa mengubah implementasi.

---

## 9. Berkas bukti yang berkaitan

| Berkas | Isi |
|---|---|
| `docs/flutter_test.log` | log `flutter test` terakhir (60 test) |
| `docs/flutter_analyze.log` | log `flutter analyze` terakhir |
| `docs/contoh_output_gagal.log` | **contoh nyata** output gagal beserta `reason` |
| `docs/tdd/01_red.log` … `05_refactor.log` | bukti urutan TDD |
| `docs/laporan_pengujian.md` | daftar test per file |
| `docs/Variabel.md` | kontrak variabel/teks yang dikunci test |
| `docs/bug_log.md` | riwayat bug: gejala → penyebab → solusi |
