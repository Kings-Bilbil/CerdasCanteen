# Cara Menjalankan Test (untuk Anggota Lain)

Panduan singkat bila teman Anda ingin mengecek hasil testing di repo ini.

---

## 1. Letak file test

Semua file test ada di folder **`test/`** di root proyek:

```
test/
├── queue_estimator_test.dart            5 test  (inti TDD)
├── queue_estimator_diagnostic_test.dart 8 test  (diagnostik/regresi)
├── order_total_test.dart                5 test  (total keranjang)
├── json_parsing_test.dart              10 test  (parsing JSON)
├── validators_test.dart                16 test  (validasi form)
├── services_test.dart                  11 test  (notifikasi, device, formatter)
├── form_widget_test.dart                5 test  (widget test Form)
│
└── fixtures/                            kode yang diuji test
    ├── models/order.dart
    ├── models/order_item.dart
    ├── services/device_service.dart
    ├── services/notification_service.dart
    └── utils/{formatters,queue_estimator,validators}.dart
```

**Total: 60 test.**

File test yang bisa di-copy teman Anda: **seluruh isi `test/`** (7 file `.dart`)
**beserta** folder `test/fixtures/`. Fixtures wajib ikut — tanpa itu test gagal
kompilasi.

---

## 2. Cara menjalankan

### A. Paling mudah — FlutLab (tanpa instalasi)

1. Buka proyek di [flutlab.io](https://flutlab.io) (import repo GitHub, atau
   upload folder proyek).
2. Buka tab **Test**.
3. Klik **Run** — semua test dijalankan otomatis.
4. Hasil yang benar: **`60 passed`**.

Tidak perlu emulator, tidak perlu Android SDK, tidak perlu `flutter build` —
repo ini tidak memakai plugin native.

### B. Di komputer sendiri (butuh Flutter SDK)

```powershell
# 1. masuk ke folder proyek
cd path/ke/perak

# 2. unduh dependency
flutter pub get

# 3. jalankan semua test
flutter test
```

Hasil yang benar:

```
00:03 +60: All tests passed!
```

### C. Jalankan satu file saja (lebih cepat)

```powershell
flutter test test/queue_estimator_test.dart
flutter test test/validators_test.dart
```

### D. Jalankan satu test berdasarkan nama

```powershell
flutter test --plain-name "pesanan kosong"
```

### E. Tanpa Flutter — hanya ingin melihat log bukti TDD

Buka langsung file-file ini, tidak perlu tools:

| File | Isi |
|---|---|
| `docs/tdd/01_red.log` | test **gagal** (fase RED) |
| `docs/tdd/02_green.log` | test **lulus** (fase GREEN) |
| `docs/tdd/03_red.log` | test validasi **gagal** (RED siklus 2) |
| `docs/tdd/04_green.log` | semua **lulus** (GREEN siklus 2) |
| `docs/tdd/05_refactor.log` | tetap lulus setelah refactor |
| `docs/contoh_output_gagal.log` | contoh output gagal + alasan |

---

## 3. Yang harus ada di proyek

| Item | Nilai |
|---|---|
| `name` di `pubspec.yaml` | `tubes_perak` |
| dependency test | `flutter_test` (SDK) |
| dependency tambahan | tidak ada |
| Flutter minimum | `>=3.41.0` |

Kalau `pubspec.yaml` berbeda nama, import relatif di test **tetap jalan**
(karena memakai path `fixtures/...`, bukan `package:`), jadi tidak perlu
di-rename.

---

## 4. Kalau ada test merah

Jangan panik — setiap kegagalan sudah menjelaskan dirinya sendiri. Contoh:

```
00:00 +0 -1: estimasi salah [E]
  Expected: <15>
    Actual: <13>
  INPUT queueLength=3, itemCount=2 -> HARAP 15 menit.
  Bila gagal: cek minutesPerItem atau rumus di ...queue_estimator.dart.
```

Baris ketiga (yang panjang) adalah `reason:` — berisi **input, harapan, dan
dugaan penyebab**. Panduan lengkap membaca error ada di
**`docs/panduan_testing.md`** (tabel gejala G1–G14).

---

## 5. Untuk dibagikan ke teman

Yang perlu dikirim:

1. **Folder `test/`** utuh (termasuk `test/fixtures/`)
2. **`pubspec.yaml`**
3. Opsional: **`docs/`** (bukti TDD & panduan)

Yang **tidak** perlu dikirim:

- `lib/` — hanya berisi `main.dart` bawaan Flutter, tidak dipakai test
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` — tidak dipakai
  `flutter test`
- `build/`, `.dart_tool/`, `.gradle/` — artefak, jangan di-commit

Cara praktis: kirim link repo GitHub, lalu teman Anda cukup `flutter pub get`
dan `flutter test`.
