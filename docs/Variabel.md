# Variabel & Kontrak Kode — Yang Perlu Disesuaikan Saat Implementasi Sistem

Dokumen ini berisi **semua nama variabel, nama field, nama fungsi, teks pesan, dan
nilai konstanta** yang dipakai oleh test Anggota 3. Test sudah mengunci nilai-nilai
ini, jadi **implementasi sistem (Anggota 1 & 2) harus memakai nama dan nilai yang
sama** agar test tetap lulus saat diintegrasikan.

> Aturan praktis: kalau ingin mengganti nama field atau teks pesan, **ubah test-nya
> dulu** (itu TDD), jangan diam-diam mengubah kode lalu membiarkan test merah.

---

## 0. Prasyarat: nama package

| Variabel | Nilai | Dipakai di |
|---|---|---|
| Nama package (`pubspec.yaml` → `name`) | **`tubes_perak`** | Semua `import 'package:tubes_perak/...'` pada file test |

**Yang harus disesuaikan:** seluruh file test mengimpor dengan prefix
`package:tubes_perak/`. Kalau package diganti nama (mis. `cerdascanteen`), semua
import di folder `test/` wajib di-rename. Kalau tidak, test gagal karena *error
import* — bukan kegagalan test yang sah.

---

## 1. `lib/utils/queue_estimator.dart` — inti TDD (Tugas 13)

| Variabel / fungsi | Nilai / Signature | Keterangan |
|---|---|---|
| `minutesPerQueue` | `const int = 3` | menit per orang dalam antrean |
| `minutesPerItem` | `const int = 2` | menit per item pesanan |
| `estimateWaitMinutes` | `int estimateWaitMinutes({required int queueLength, required int itemCount})` | nama & named parameter **wajib sama** |

**Aturan bisnis yang dikunci test:**

| Kondisi | Perilaku wajib | Teks `ArgumentError` |
|---|---|---|
| `queueLength < 0` **atau** `itemCount < 0` | `throw ArgumentError` | `'Nilai tidak boleh negatif'` |
| `itemCount == 0` | `throw ArgumentError` | `'Pesanan harus berisi minimal 1 item'` |
| selain itu | `return (queueLength * 3) + (itemCount * 2)` | — |

Contoh teruji: `queueLength: 0, itemCount: 1` → **2**; `queueLength: 3, itemCount: 2` → **13**.

**Yang harus disesuaikan implementasi:**

1. Kalau layar checkout punya rumus sendiri (mis. menit per antrean = 2,5), **jangan
   ditulis ulang di widget**. Panggil `estimateWaitMinutes` supaya nilai tetap satu sumber.
2. Kalau `minutesPerQueue`/`minutesPerItem` ingin diubah (mis. hasil kalibrasi data
   antrean di `docs/analisis_tugas13.md`), ubah **konstantanya saja** — test rumus
   (`0/1→2`, `3/2→13`) akan gagal sehingga harus diperbarui bersamaan. Itu memang tujuan TDD.
3. Alur checkout **tidak boleh** memanggil fungsi ini dengan `itemCount: 0`; validasi
   keranjang kosong dilakukan lewat `CheckoutRules` (bagian 5) sebelum memanggil estimator,
   agar tidak terjadi `ArgumentError` yang tidak tertangani.

---

## 2. `lib/models/order_item.dart` — model item keranjang

### Field objek

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `name` | `String` | ya | nama menu |
| `price` | `int` | ya | harga satuan, **rupiah, bilangan bulat** (bukan `double`) |
| `qty` | `int` | ya | jumlah pesan |

- Konstruktor: `const OrderItem({required String name, required int price, required int qty})`
- Getter: `int get subtotal` → `price * qty`
- `Map<String, dynamic> toJson()`
- `factory OrderItem.fromJson(Map<String, dynamic> json)`

### Kunci JSON yang diterima (urutan prioritas)

| Data | Kunci utama | Alias yang juga diterima | Default |
|---|---|---|---|
| nama | `nama` | `name` | — (wajib) |
| harga | `harga` | `price` | — (wajib) |
| jumlah | `qty` | `jumlah` | **`1`** bila tidak dikirim |

**Yang harus disesuaikan implementasi API/model:**

1. Harga **harus `int`**. Test memeriksa `item.price == 15000`. Kalau backend mengirim
   `15000.0` (double) atau `"15000"` (string), `fromJson` sudah menanganinya — tetapi
   jangan mengubah field `price` menjadi `double`, karena `formatRupiah(int)` dan
   `subtotal` bertipe `int`.
2. Kalau backend memakai nama field lain (mis. `menu_name`, `unit_price`, `quantity`),
   tambahkan alias di `OrderItem.fromJson`, **jangan** ganti nama `name`/`price`/`qty`.
3. `qty` default `1` dipertahankan test ("mendukung alias field bahasa Inggris"),
   jadi jangan mengubah default menjadi `0`.

### Aturan validasi `fromJson` (semua → `FormatException`)

| Kondisi | Pesan |
|---|---|
| `nama`/`name` tidak ada, bukan `String`, atau kosong/spasi | `'Field "nama" wajib ada dan berupa teks'` |
| `harga`/`price` tidak ada | `'Field "harga" tidak ditemukan'` |
| `harga` bukan int/double/string angka | `'Field "harga" tidak valid: <nilai>'` |
| `harga < 0` | `'Harga tidak boleh negatif'` |
| `qty <= 0` | `'Jumlah item harus minimal 1'` |
| field lain tidak valid | `'Field "<field>" tidak valid: <nilai>'` |

Nilai `double` diubah dengan `.toInt()`; `String` diparse dengan `int.tryParse` (setelah `trim()`).

---

## 3. `lib/models/order.dart` — model pesanan & status

### Enum `OrderStatus`

| Nilai enum | `label` (dipakai UI & JSON) |
|---|---|
| `OrderStatus.diproses` | `'Diproses'` |
| `OrderStatus.siapDiambil` | `'Siap Diambil'` |
| `OrderStatus.selesai` | `'Selesai'` |

- `static OrderStatus fromString(String value)` — mencocokkan `label` **atau** `name`
  (case-insensitive, `trim()`). Nilai tak dikenal → **`OrderStatus.diproses`**
  (tidak melempar error).

**Yang harus disesuaikan implementasi:** semua tempat yang menampilkan status ke
pengguna harus memakai `status.label`, **bukan** `status.name`, supaya teks
"**Siap Diambil**" (dengan spasi & huruf kapital) tetap konsisten. Test widget
mencari teks persis `'Siap Diambil'` dan `'Diproses'`.

### Field `Order`

| Field | Tipe | Default | Keterangan |
|---|---|---|---|
| `id` | `String` | — (wajib) | kode pesanan, mis. `CC-2024` |
| `items` | `List<OrderItem>` | — (wajib) | isi keranjang |
| `status` | `OrderStatus` | `OrderStatus.diproses` | status awal setelah checkout |
| `queueLength` | `int` | **`0`** | jumlah orang mengantre **di depan** pesanan ini |

- `const Order({required String id, required List<OrderItem> items, OrderStatus status = OrderStatus.diproses, int queueLength = 0})`
- `int get totalPrice` → jumlah `subtotal` semua item (contoh: 2×15.000 + 3×5.000 = **45000**)
- `int get totalItems` → jumlah **kuantitas** (contoh di atas = **5**), bukan jumlah baris
- `bool get isEmpty` → `items.isEmpty`
- `fromJson` / `toJson`

### Kunci JSON `Order`

| Data | Kunci JSON | Default bila tidak ada |
|---|---|---|
| id | `id` | `''` |
| item | `items` (**wajib `List`**) | — (`FormatException` bila bukan array) |
| status | `status` | `diproses` |
| panjang antrean | `queue_length` | `0` |

**Yang harus disesuaikan implementasi:**

1. `totalPrice` **belum** menghitung diskon/pajak/biaya layanan. Kalau fitur diskon
   ditambahkan, buat getter baru (mis. `grandTotal`) — **jangan ubah `totalPrice`**,
   karena test total keranjang mengunci angka 45000/12000/0.
2. `queueLength` adalah **jumlah orang di depan**, termasuk nol. Jangan diganti menjadi
   `estimatedMinutes` atau `posisiAntrean`, karena nama ini dipakai `QrReceiptScreen`
   dan `estimateWaitMinutes(queueLength: ...)`.
3. Kunci `queue_length` (snake_case) dipertahankan. Kalau backend memakai
   `queueLength`/`antrean`, tambahkan alias di `Order.fromJson`.
4. Setiap item di `items` **harus** objek (`Map`); kalau tidak →
   `FormatException('Setiap item harus berupa objek')`. `items` bukan `List` →
   `FormatException('Field "items" harus berupa array')`.

---

## 4. `lib/services/notification_service.dart` — fitur native Tugas 12

### `NotificationContent`

| Field | Tipe |
|---|---|
| `title` | `String` |
| `body` | `String` |

`const NotificationContent({required String title, required String body})`,
punya `==`, `hashCode`, dan `toString()` → `'$title | $body'`.

### `buildOrderStatusContent` (fungsi murni yang diuji)

```dart
NotificationContent buildOrderStatusContent(
  OrderStatus status, {
  String? orderId,
  int? estimateMinutes,
})
```

`final String suffix = (orderId == null || orderId.isEmpty) ? '' : ' #$orderId';`

| Status | `title` | `body` |
|---|---|---|
| `diproses` | `'Pesanan$suffix Diproses'` | `'Pesananmu sedang dibuat oleh kantin. Mohon tunggu sebentar ya.'` |
| `siapDiambil` | `'Pesanan$suffix Siap Diambil!'` | `'Silakan ambil pesananmu di konter kantin sebelum dingin.'` + `estimasi` |
| `selesai` | `'Pesanan$suffix Selesai'` | `'Terima kasih sudah memesan di CerdasCanteen. Selamat makan!'` |

`estimasi` = `''` bila `estimateMinutes == null`, atau
`' Estimasi tunggu ±$estimateMinutes menit.'` (ada spasi di depan, tanda `±`).

**Yang harus disesuaikan implementasi:** teks `title`/`body` di atas adalah yang
diperiksa test (`contains('Diproses')`, `contains('±9 menit')`, dsb). Kalau desain
notifikasi diubah, ubah test-nya juga. Perhatikan `orderId` kosong harus
**tidak** memunculkan `#` (test: `isNot(contains('#'))`).

### Kontrak `NotificationService` yang perlu dibuat Anggota 1

Kelas ini **sudah ditarik dari repo** (bukan scope testing), tetapi kontraknya
harus dipenuhi saat implementasi:

| Anggota | Nilai / Signature |
|---|---|
| `NotificationService.instance` | singleton |
| `channelId` | `'cerdascanteen_order_status'` |
| `channelName` | `'Status Pesanan'` |
| `channelDescription` | `'Notifikasi perubahan status pesanan CerdasCanteen'` |
| `bool get isInitialized` | status inisialisasi plugin |
| `bool get permissionGranted` | hasil permintaan izin |
| `Future<bool> init()` | idempotent, tidak boleh melempar exception |
| `Future<bool> requestPermission()` | Android 13+ (`POST_NOTIFICATIONS`), iOS, web |
| `Future<bool> showOrderStatus(OrderStatus status, {String? orderId, int? estimateMinutes, int? notificationId})` | memakai `buildOrderStatusContent` |
| `Future<bool> showOrderStatusForOrder(Order order, {int? estimateMinutes})` | shortcut |

**Yang harus disesuaikan implementasi:**

1. Title/body **wajib** diambil dari `buildOrderStatusContent` — jangan ditulis ulang,
   agar teks notifikasi dan test tetap satu sumber.
2. Izin ditolak **bukan** error: `requestPermission()` mengembalikan `false`, dan UI
   **wajib** menampilkan penjelasan (dialog/snackbar), bukan diam saja
   (bug ini tercatat sebagai BUG-004 di `docs/bug_log.md`).
3. Dependency yang perlu ditambahkan kembali saat implementasi:
   `flutter_local_notifications`. Untuk `flutter_local_notifications` ≥ v10,
   Android **butuh** `isCoreLibraryDesugaringEnabled = true` dan
   `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`
   (BUG-005). Izin di `AndroidManifest.xml`: `POST_NOTIFICATIONS`, `VIBRATE`.

---

## 5. `lib/utils/validators.dart` — validasi form login/register

Semua fungsi bersifat `static` dan **mengembalikan `String?`** (`null` = valid).
Teks pesan di bawah **diperiksa persis** oleh test.

### `Validators.email(String? value)`

| Kondisi | Return |
|---|---|
| kosong / hanya spasi / `null` | `'Email wajib diisi'` |
| tidak cocok regex | `'Format email tidak valid'` |
| cocok | `null` |

Regex: `^[\w.+-]+@[\w-]+\.[\w.-]+$` (input di-`trim()` lebih dulu).
Contoh valid teruji: `mahasiswa@kampus.ac.id`, `  budi.s@mail.com  `.
Contoh ditolak: `tanpa-at`, `budi@`, `budi@kampus` (domain tanpa titik).

### `Validators.password(String? value)`

| Kondisi | Return |
|---|---|
| `''` | `'Password wajib diisi'` |
| panjang `< 8` | `'Password minimal 8 karakter'` |
| panjang `>= 8` | `null` |

### `Validators.nama(String? value)`

| Kondisi | Return |
|---|---|
| kosong / hanya spasi | `'Nama wajib diisi'` |
| panjang `< 3` | `'Nama minimal 3 karakter'` |
| lainnya | `null` |

### `Validators.konfirmasiPassword(String? value, String password)`

| Kondisi | Return |
|---|---|
| kosong | `'Konfirmasi password wajib diisi'` |
| berbeda dari `password` | `'Konfirmasi password tidak sama'` |
| sama | `null` |

### `Validators.isFormValid(List<String?> errors)`

`true` bila **semua** elemen `null`.

### `CheckoutRules` — penilaian proses sistem (Tugas 13)

| Fungsi | Perilaku |
|---|---|
| `String? validateCart({required int itemCount})` | `itemCount <= 0` → `'Keranjang kosong, tidak bisa checkout'`; selain itu `null` |
| `bool canCheckout({required int itemCount})` | `validateCart(...) == null` |

**Yang harus disesuaikan implementasi:**

1. Tombol "Checkout" **wajib** memanggil `CheckoutRules.canCheckout(itemCount: ...)`
   dan menonaktifkan/menolak aksi bila `false`. Inilah bukti "checkout dengan
   keranjang kosong ditolak" yang dinilai pada Tugas 13.
2. Gunakan `Validators.*` sebagai `validator:` pada `TextFormField` login/register,
   jangan menulis ulang aturan (mis. minimal password) di widget.
3. Kalau backend punya aturan lebih ketat (mis. password harus ada angka), perbarui
   **test dan dokumen ini** bersamaan.
4. Minimal password = **8**, minimal nama = **3**. Angka ini diuji.

---

## 6. `lib/utils/formatters.dart`

| Fungsi | Signature | Contoh teruji |
|---|---|---|
| `formatRupiah` | `String formatRupiah(int amount)` | `15000` → `'Rp15.000'`; `500` → `'Rp500'`; `1234567` → `'Rp1.234.567'`; `0` → `'Rp0'` |
| `formatEstimasiMenit` | `String formatEstimasiMenit(int minutes)` | `13` → `'13 menit'`; `65` → `'1 jam 5 menit'`; `120` → `'2 jam'` |

Detail: `formatRupiah` memakai titik sebagai pemisah ribuan dan awalan `Rp` **tanpa spasi**;
nilai negatif diberi tanda `-` sebelum `Rp`.
`formatEstimasiMenit` memakai `'N menit'` bila `< 60`, `'X jam N menit'` bila ada sisa,
dan `'X jam'` bila sisa `0`.

**Yang harus disesuaikan implementasi:** semua tampilan harga memakai `formatRupiah`,
semua tampilan estimasi memakai `formatEstimasiMenit`. Kalau memakai
`intl`/`NumberFormat.currency`, hasilnya harus tetap sama persis (`Rp15.000`), atau
test formatter diperbarui.

---

## 7. `lib/services/device_service.dart` — fitur native info perangkat

### `DeviceInfoEntry`

`const DeviceInfoEntry(String label, String value)`; punya `==`, `hashCode`,
`toString()` → `'$label: $value'`.

### `DeviceSummary`

| Anggota | Keterangan |
|---|---|
| `const DeviceSummary(List<DeviceInfoEntry> entries)` | — |
| `bool get isEmpty` | `entries.isEmpty` |
| `List<DeviceInfoEntry> get displayed` | hanya entri yang `value.trim().isNotEmpty` |

### `DeviceSummary.fromRaw({...})` — parameter & label yang dihasilkan

| Parameter | Tipe | Label entri yang muncul |
|---|---|---|
| `manufacturer` + `model` | `String?` | `'Perangkat'` → `'<manufacturer> <model>'` (bagian kosong dilewati) |
| `brand` | `String?` | `'Merek'` |
| `device` | `String?` | `'Nama internal'` |
| `androidVersion` (+ `sdkInt`) | `String?`, `int?` | `'Versi Android'` → `'Android 13 (API 33)'`; bila `androidVersion` kosong tetapi `sdkInt` ada → `'API Level'` → `'33'` |
| `iosName` | `String?` | `'Perangkat iOS'` |
| `iosModel` | `String?` | `'Model iOS'` |
| `iosSystemVersion` | `String?` | `'Versi iOS'` |
| `webBrowserName` | `String?` | `'Browser'` |
| `webPlatform` | `String?` | `'Platform Web'` |
| `fcmToken` | `String?` | `'Token notifikasi'` (dipotong) |
| `now` | `DateTime?` | `'Login terakhir'` → format `dd/MM/yyyy HH:mm` (default `DateTime.now()`) |

**Aturan detail yang diuji:**

- Entri dengan nilai kosong/spasi **tidak dibuat** (test: "data kosong tidak
  menghasilkan entri kosong").
- `'Login terakhir'` **selalu** ada, format `05/01/2026 09:07` (dua digit, leading zero).
- Token: panjang ≤ 16 ditampilkan utuh; lebih dari itu → `8 karakter pertama` +
  `…` + `6 karakter terakhir` (test: total `< 27` karakter dan mengandung `'…'`).

**Yang harus disesuaikan implementasi:**

1. Nama label (`'Perangkat'`, `'Versi Android'`, `'Login terakhir'`, …) dipakai test
   widget. Kalau UI ingin label lain, ubah test sekaligus.
2. Saat plugin gagal, **wajib** memakai fallback `DeviceSummary.fromRaw(model: 'Tidak diketahui')`
   (test: teks `'Tidak diketahui'` muncul, dan **tidak** ada teks `'Gagal membaca'`).
3. Dependency: `device_info_plus` (ditarik dari repo saat ini, tambahkan kembali saat
   implementasi). Tidak butuh izin runtime.

### Kontrak `DeviceService` (injection untuk test)

| Anggota | Signature |
|---|---|
| typedef | `typedef DeviceSummaryLoader = Future<DeviceSummary> Function();` |
| konstruktor | `DeviceService({DeviceInfoPlugin? plugin, DeviceSummaryLoader? loader})` |
| singleton | `static final DeviceService instance` |
| utama | `Future<DeviceSummary> load({bool forceRefresh = false})` |
| tambahan | `void clearCache()` |

**Penting (BUG-007):** jalur `loader` **wajib** dipertahankan. Di `flutter test`,
plugin native tidak menjawab sehingga `Future` tidak pernah selesai dan widget test
mengalami `pumpAndSettle timed out`. Test memakai `DeviceService(loader: ...)`.
`load()` juga wajib membungkus pemanggilan plugin dengan `try/catch`.

---

## 8. Variabel khusus test (tidak perlu diubah implementasi)

Nilai berikut hanya hidup di dalam file test, dicatat agar tidak dikira bagian sistem.

| File | Variabel | Nilai |
|---|---|---|
| `test/form_widget_test.dart` | `_emailKey` | `Key('email-field')` |
| `test/form_widget_test.dart` | `_submitKey` | `Key('submit-button')` |
| `test/form_widget_test.dart` | `_submittedValue` | penanda `'terkirim'` |
| `test/queue_estimator_test.dart` | data uji | `(0,1)→2`, `(3,2)→13`, `(-1,1)`, `(1,-1)`, `(2,0)` |
| `test/order_total_test.dart` | `id` contoh | `CC-1`, `CC-2`, `CC-3` |
| `test/json_parsing_test.dart` | `id` contoh | `CC-100`, `CC-101`, `CC-7` |
| `test/services_test.dart` | data perangkat | `samsung`/`SM-A525F`/API 33; `DateTime(2026,1,5,9,7)` |

`test/form_widget_test.dart` sengaja merakit `Form` + `TextFormField` sendiri
(tidak mengimpor `lib/screens/**`), sehingga tetap jalan di FlutLab walau layar
login/register belum dibuat.

---

## 9. Ringkasan: yang wajib ditambahkan kembali saat implementasi sistem

Saat ini repo **hanya berisi kode yang diuji + test** (sesuai instruksi: "hanya
membuat testing"). Yang sudah ditarik dan perlu dibuat ulang oleh tim:

| Item | Status | Catatan |
|---|---|---|
| `lib/screens/qr_receipt_screen.dart` | ditarik | kontrak widget test ada di `docs/rencana_test/qr_receipt_screen_test.dart.pending` |
| `lib/screens/profile_screen.dart` | ditarik | kontrak ada di `docs/rencana_test/profile_screen_test.dart.pending` |
| `lib/main_anggota3_demo.dart` | ditarik | entry point demo |
| `NotificationService` (kelas plugin) | ditarik | kontrak di bagian 4 |
| `DeviceService` (kelas plugin) | ditarik | kontrak di bagian 7 |
| dependency `device_info_plus`, `flutter_local_notifications`, `qr_flutter` | ditarik dari `pubspec.yaml` | tambahkan kembali saat memakai |
| konfigurasi Android (desugaring, `POST_NOTIFICATIONS`) | dikembalikan ke asli | lihat BUG-005 |

Dua file `*.pending` di `docs/rencana_test/` **bukan** test aktif (tidak dijalankan
`flutter test` karena berekstensi `.pending`). Setelah layar dibuat, pindahkan ke
`test/` dan hapus akhiran `.pending`.

### Kontrak layar yang harus dipenuhi agar widget test tadi bisa diaktifkan

| Layar | Kontrak minimum |
|---|---|
| `QrReceiptScreen` | konstruktor `QrReceiptScreen({required Order order, int? estimateMinutes})`; getter `int get resolvedEstimate` (fallback `0` bila `ArgumentError`); getter `String get qrData` berisi `CERDASCANTEEN`, `ID:<id>`, `ITEM:<totalItems>`, `TOTAL:<totalPrice>`, `EST:<estimasi>`, `STATUS:<label uppercase>`; memakai `QrImageView` (`qr_flutter`) |
| `ProfileScreen` | konstruktor `ProfileScreen({String studentName, String studentId, DeviceService? deviceService, ...})`; menampilkan `'Informasi Perangkat'`, `'Notifikasi Pesanan'`, dan tombol `'Coba Notifikasi "Siap Diambil"'`; menerima `DeviceService` untuk injeksi |

---

## 10. Cara memverifikasi setelah implementasi

```bash
flutter pub get
flutter test                      # harus "All tests passed!"
flutter analyze                   # harus "No issues found!"
```

Setelah layar dibuat, aktifkan kembali widget test yang diparkir:

```powershell
Move-Item docs/rencana_test/qr_receipt_screen_test.dart.pending test/qr_receipt_screen_test.dart
Move-Item docs/rencana_test/profile_screen_test.dart.pending test/profile_screen_test.dart
flutter test
```

Kalau ada test merah setelah integrasi, penyebab tersering adalah **nama field,
label status, atau teks pesan yang berbeda** dari tabel di dokumen ini — bukan
kesalahan pada data uji.
