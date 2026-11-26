# Variabel yang Dipakai Testing — Daftar untuk Developer

Daftar **nama variabel, field, konstanta, dan teks** yang dipakai test Anggota 3.
Developer (Anggota 1 & 2) cukup menyesuaikan nama/nilai di bawah ini agar test
tetap lulus saat diintegrasikan.

**Lokasi kode yang diuji:** `test/fixtures/` (bukan `lib/`, agar tidak bentrok).
**Lokasi test:** `test/*.dart`

---

## 1. `test/fixtures/utils/queue_estimator.dart`

**Konstanta**

| Nama | Nilai |
|---|---|
| `minutesPerQueue` | `3` |
| `minutesPerItem` | `2` |

**Fungsi**

| Nama | Signature |
|---|---|
| `estimateWaitMinutes` | `int estimateWaitMinutes({required int queueLength, required int itemCount})` |

**Parameter**

| Nama | Tipe |
|---|---|
| `queueLength` | `int` |
| `itemCount` | `int` |

**Teks pesan error (harus persis)**

| Kondisi | Teks |
|---|---|
| nilai negatif | `Nilai tidak boleh negatif` |
| `itemCount == 0` | `Pesanan harus berisi minimal 1 item` |

---

## 2. `test/fixtures/models/order_item.dart` — class `OrderItem`

**Field**

| Nama field | Tipe | Keterangan |
|---|---|---|
| `name` | `String` | wajib |
| `price` | `int` | wajib, harga satuan |
| `qty` | `int` | wajib, minimal 1 |

**Getter**

| Nama | Tipe | Rumus |
|---|---|---|
| `subtotal` | `int` | `price * qty` |

**Key JSON masuk (`fromJson`)**

| Key | Alias yang diterima | Tipe | Default |
|---|---|---|---|
| `nama` | `name` | `String` | wajib |
| `harga` | `price` | `int` / `double` / `String` angka | wajib |
| `qty` | `jumlah` | `int` / `double` / `String` angka | `1` |

**Key JSON keluar (`toJson`)**: `nama`, `harga`, `qty`

**Teks pesan error (harus persis)**

| Kondisi | Teks |
|---|---|
| nama kosong / bukan teks | `Field "nama" wajib ada dan berupa teks` |
| harga negatif | `Harga tidak boleh negatif` |
| qty ≤ 0 | `Jumlah item harus minimal 1` |
| field angka tidak ada | `Field "<nama field>" tidak ditemukan` |
| field angka tidak valid | `Field "<nama field>" tidak valid: <value>` |

---

## 3. `test/fixtures/models/order.dart` — enum `OrderStatus` + class `Order`

**Enum `OrderStatus`**

| Nilai enum | `label` |
|---|---|
| `diproses` | `Diproses` |
| `siapDiambil` | `Siap Diambil` |
| `selesai` | `Selesai` |

Fungsi: `OrderStatus.fromString(String value)` — fallback ke `diproses`.

**Field `Order`**

| Nama field | Tipe | Default |
|---|---|---|
| `id` | `String` | wajib |
| `items` | `List<OrderItem>` | wajib |
| `status` | `OrderStatus` | `OrderStatus.diproses` |
| `queueLength` | `int` | `0` |

**Getter `Order`**

| Nama | Tipe | Rumus |
|---|---|---|
| `totalPrice` | `int` | Σ `item.subtotal` |
| `totalItems` | `int` | Σ `item.qty` |
| `isEmpty` | `bool` | `items.isEmpty` |

**Key JSON masuk (`fromJson`)**

| Key | Tipe | Default |
|---|---|---|
| `id` | `String` | `''` |
| `items` | `List` (wajib ada) | — |
| `status` | `String` | `Diproses` |
| `queue_length` | `int` | `0` |

**Key JSON keluar (`toJson`)**: `id`, `items`, `status`, `queue_length`

**Teks pesan error (harus persis)**

| Kondisi | Teks |
|---|---|
| `items` bukan array | `Field "items" harus berupa array` |
| elemen bukan objek | `Setiap item harus berupa objek` |

---

## 4. `test/fixtures/services/notification_service.dart`

**Class `NotificationContent`**

| Field | Tipe |
|---|---|
| `title` | `String` |
| `body` | `String` |

**Fungsi**

| Nama | Signature |
|---|---|
| `buildOrderStatusContent` | `NotificationContent buildOrderStatusContent(OrderStatus status, {String? orderId, int? estimateMinutes})` |

**Teks `title` (harus persis)**

| Status | Tanpa `orderId` | Dengan `orderId` |
|---|---|---|
| `diproses` | `Pesanan Diproses` | `Pesanan #<id> Diproses` |
| `siapDiambil` | `Pesanan Siap Diambil!` | `Pesanan #<id> Siap Diambil!` |
| `selesai` | `Pesanan Selesai` | `Pesanan #<id> Selesai` |

**Teks `body` (harus persis)**

| Status | Body |
|---|---|
| `diproses` | `Pesananmu sedang dibuat oleh kantin. Mohon tunggu sebentar ya.` |
| `siapDiambil` | `Silakan ambil pesananmu di konter kantin sebelum dingin.` + ` Estimasi tunggu ±<N> menit.` (hanya bila `estimateMinutes` tidak null) |
| `selesai` | `Terima kasih sudah memesan di CerdasCanteen. Selamat makan!` |

**Kontrak `NotificationService` (belum ada di repo, dibutuhkan saat implementasi)**

| Item | Nilai |
|---|---|
| `channelId` | `cerdascanteen_order_status` |
| `channelName` | `Status Pesanan` |

| Method | Signature |
|---|---|
| `init` | `Future<void> init()` |
| `requestPermission` | `Future<bool> requestPermission()` |
| `showOrderStatus` | `Future<void> showOrderStatus(OrderStatus status, {String? orderId, int? estimateMinutes, int? notificationId})` |

---

## 5. `test/fixtures/utils/validators.dart`

**Class `Validators`** (semua `static`)

| Method | Signature |
|---|---|
| `email` | `String? email(String? value)` |
| `password` | `String? password(String? value)` |
| `nama` | `String? nama(String? value)` |
| `konfirmasiPassword` | `String? konfirmasiPassword(String? value, String password)` |
| `isFormValid` | `bool isFormValid(List<String?> errors)` |

**Batas nilai**

| Aturan | Nilai |
|---|---|
| panjang minimal password | `8` karakter |
| panjang minimal nama | `3` karakter |

**Teks pesan error (harus persis)**

| Kondisi | Teks |
|---|---|
| email kosong | `Email wajib diisi` |
| format email salah | `Format email tidak valid` |
| password kosong | `Password wajib diisi` |
| password < 8 | `Password minimal 8 karakter` |
| nama kosong | `Nama wajib diisi` |
| nama < 3 | `Nama minimal 3 karakter` |
| konfirmasi kosong | `Konfirmasi password wajib diisi` |
| konfirmasi beda | `Konfirmasi password tidak sama` |

**Class `CheckoutRules`**

| Method | Signature |
|---|---|
| `validateCart` | `String? validateCart({required int itemCount})` |
| `canCheckout` | `bool canCheckout({required int itemCount})` |

| Kondisi | Teks |
|---|---|
| `itemCount <= 0` | `Keranjang kosong, tidak bisa checkout` |

---

## 6. `test/fixtures/utils/formatters.dart`

| Nama | Signature | Contoh |
|---|---|---|
| `formatRupiah` | `String formatRupiah(int amount)` | `15000` → `Rp15.000` |
| `formatEstimasiMenit` | `String formatEstimasiMenit(int minutes)` | `13` → `13 menit`<br>`65` → `1 jam 5 menit`<br>`120` → `2 jam` |

---

## 7. `test/fixtures/services/device_service.dart`

**Class `DeviceInfoEntry`**

| Field | Tipe |
|---|---|
| `label` | `String` |
| `value` | `String` |

Constructor: `DeviceInfoEntry(String label, String value)`

**Class `DeviceSummary`**

| Field / getter | Tipe |
|---|---|
| `entries` | `List<DeviceInfoEntry>` |
| `isEmpty` | `bool` |
| `displayed` | `List<DeviceInfoEntry>` |

| Method | Signature |
|---|---|
| `DeviceSummary.fromRaw` | `factory DeviceSummary.fromRaw({String? manufacturer, String? model, String? brand, String? device, String? androidVersion, int? sdkInt, String? iosName, String? iosSystemVersion, String? iosModel, String? webBrowserName, String? webPlatform, String? fcmToken, DateTime? now})` |

**Label yang dihasilkan `fromRaw`**

| Parameter | Label entri |
|---|---|
| `manufacturer` + `model` | `Perangkat` |
| `brand` | `Merek` |
| `device` | `Nama internal` |
| `androidVersion` (+ `sdkInt`) | `Versi Android` (contoh `Android 13 (API 33)`) |
| `sdkInt` saja | `API Level` |
| `iosName` | `Perangkat iOS` |
| `iosModel` | `Model iOS` |
| `iosSystemVersion` | `Versi iOS` |
| `webBrowserName` | `Browser` |
| `webPlatform` | `Platform Web` |
| `fcmToken` | `Token notifikasi` |
| `now` (atau `DateTime.now()`) | `Login terakhir` |

**Aturan pemotongan `fcmToken`**: panjang ≤ 16 → utuh; lebih dari 16 →
`8 karakter awal` + `…` + `6 karakter akhir`

**Format `Login terakhir`**: `dd/MM/yyyy HH:mm`

**Nilai fallback** saat data gagal dibaca: `Tidak diketahui`

| Item | Nilai |
|---|---|
| tipe injeksi test | `typedef DeviceSummaryLoader = Future<DeviceSummary> Function();` |
| constructor | `DeviceService({DeviceInfoPlugin? plugin, DeviceSummaryLoader? loader})` |
| method | `Future<DeviceSummary> load({bool forceRefresh = false})` |
| method | `void clearCache()` |

---

## 8. Variabel khusus test (tidak perlu diubah developer)

| Nama | Nilai | Dipakai di |
|---|---|---|
| `_emailKey` | `Key('email-field')` | `form_widget_test.dart` |
| `_submitKey` | `Key('submit-button')` | `form_widget_test.dart` |
| penanda submit | `terkirim` | `form_widget_test.dart` |

---

## 9. Fitur yang belum ada kodenya (perlu dibuat developer)

| Path yang dibutuhkan | Isi minimum |
|---|---|
| `lib/screens/qr_receipt_screen.dart` | getter `resolvedEstimate` (int), getter `qrData` (String) berisi baris `CERDASCANTEEN`, `ID:`, `ITEM:`, `TOTAL:`, `EST:`, `STATUS:` |
| `lib/screens/profile_screen.dart` | menampilkan `DeviceSummary.entries`, tombol notifikasi |
| `lib/notifikasi` (class `NotificationService`) | sesuai kontrak bagian 4 |
| `lib/services/device_service.dart` (jalur plugin) | `load()` + `clearCache()`, wajib bisa diinjeksi `DeviceSummaryLoader` |

Widget test untuk kedua layar diparkir di `docs/rencana_test/*.pending`.

---

## 10. Cara memakai daftar ini saat integrasi

1. Implementasikan fitur di `lib/` (atau path yang disepakati tim).
2. Ubah import di file test dari `fixtures/...` menjadi
   `package:tubes_perak/...` sesuai lokasi baru.
3. **Jangan ubah** nama field, nama fungsi, signature, dan teks pesan pada
   dokumen ini — test menguncinya.
4. Jalankan `flutter test`. Bila ada yang merah, baca `reason:` pada output
   (panduan lengkap: `docs/panduan_testing.md`).
