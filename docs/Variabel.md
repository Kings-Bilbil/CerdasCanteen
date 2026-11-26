# Variabel yang Dipakai Testing — Daftar untuk Developer

Daftar **nama variabel, field, konstanta, dan teks** yang dikunci oleh test.
Developer (Anggota 1 & 2) cukup menyesuaikan nama/nilai di bawah ini agar test
tetap lulus saat diintegrasikan.

- **Lokasi kode yang diuji:** `test/fixtures/` (bukan `lib/`, agar tidak bentrok)
- **Lokasi test:** `test/*.dart`
- **Jumlah test:** 22 (19 unit + 3 widget)

---

## 1. `test/fixtures/utils/queue_estimator.dart`

**Konstanta**

| Nama | Nilai |
|---|---|
| `minutesPerQueue` | `3` |
| `minutesPerItem` | `2` |

**Parameter**

| Nama | Tipe |
|---|---|
| `queueLength` | `int` |
| `itemCount` | `int` |

**Fungsi**

| Nama | Signature |
|---|---|
| `estimateWaitMinutes` | `int estimateWaitMinutes({required int queueLength, required int itemCount})` |

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

| Key | Alias diterima | Tipe | Default |
|---|---|---|---|
| `nama` | `name` | `String` | wajib |
| `harga` | `price` | `int` / `double` / `String` angka | wajib |
| `qty` | `jumlah` | `int` / `double` / `String` angka | `1` |

**Key JSON keluar (`toJson`):** `nama`, `harga`, `qty`

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

**Key JSON keluar (`toJson`):** `id`, `items`, `status`, `queue_length`

**Teks pesan error (harus persis)**

| Kondisi | Teks |
|---|---|
| `items` bukan array | `Field "items" harus berupa array` |
| elemen bukan objek | `Setiap item harus berupa objek` |

---

## 4. `test/fixtures/utils/validators.dart`

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

## 5. Variabel khusus widget test (tidak perlu diubah developer)

| Nama | Nilai | Dipakai di |
|---|---|---|
| `_emailKey` | `Key('email-field')` | `form_widget_test.dart` |
| `_submitKey` | `Key('submit-button')` | `form_widget_test.dart` |
| penanda submit | `terkirim` | `form_widget_test.dart` |

---

## 6. Fitur Tugas 12 yang belum ada kodenya (kontrak untuk developer)

Bagian ini **tidak diuji** saat ini, tetapi nilainya sudah ditentukan agar
implementasi konsisten bila test-nya ditambahkan nanti.

**Notifikasi status pesanan**

| Item | Nilai |
|---|---|
| `title` Diproses | `Pesanan Diproses` / `Pesanan #<id> Diproses` |
| `title` Siap Diambil | `Pesanan Siap Diambil!` / `Pesanan #<id> Siap Diambil!` |
| `title` Selesai | `Pesanan Selesai` / `Pesanan #<id> Selesai` |
| `body` Diproses | `Pesananmu sedang dibuat oleh kantin. Mohon tunggu sebentar ya.` |
| `body` Siap Diambil | `Silakan ambil pesananmu di konter kantin sebelum dingin.` + ` Estimasi tunggu ±<N> menit.` |
| `body` Selesai | `Terima kasih sudah memesan di CerdasCanteen. Selamat makan!` |
| `channelId` | `cerdascanteen_order_status` |
| `channelName` | `Status Pesanan` |

**Formatter**

| Nama | Signature | Contoh |
|---|---|---|
| `formatRupiah` | `String formatRupiah(int amount)` | `15000` → `Rp15.000` |
| `formatEstimasiMenit` | `String formatEstimasiMenit(int minutes)` | `13` → `13 menit`<br>`65` → `1 jam 5 menit`<br>`120` → `2 jam` |

**Info perangkat**

| Item | Nilai |
|---|---|
| label | `Perangkat`, `Merek`, `Nama internal`, `Versi Android`, `API Level`, `Perangkat iOS`, `Model iOS`, `Versi iOS`, `Browser`, `Platform Web`, `Token notifikasi`, `Login terakhir` |
| fallback data gagal | `Tidak diketahui` |
| format tanggal | `dd/MM/yyyy HH:mm` |
| injeksi untuk test | `typedef DeviceSummaryLoader = Future<DeviceSummary> Function();` |

**Layar (belum dibuat)**

| Path | Isi minimum |
|---|---|
| `lib/screens/qr_receipt_screen.dart` | getter `resolvedEstimate` (int) dan `qrData` (String) berisi baris `CERDASCANTEEN`, `ID:`, `ITEM:`, `TOTAL:`, `EST:`, `STATUS:` |
| `lib/screens/profile_screen.dart` | menampilkan ringkasan perangkat + tombol notifikasi |

---

## 7. Cara memakai daftar ini saat integrasi

1. Implementasikan fitur di `lib/` (atau path yang disepakati tim).
2. Ubah import di file test dari `fixtures/...` menjadi
   `package:tubes_perak/...` sesuai lokasi baru.
3. **Jangan ubah** nama field, nama fungsi, signature, dan teks pesan pada
   dokumen ini — test menguncinya.
4. Jalankan `flutter test`. Bila ada yang merah, baca baris `reason:` pada
   output test — isinya input, harapan, dan dugaan penyebabnya.
