# Analisis Ekosistem & Keputusan Teknis CerdasCanteen

Dokumen ini memenuhi Tugas 1 (Anggota 3): alasan pemilihan Flutter, perbandingan
dengan Native (Kotlin) dan React Native, platform yang dipakai beserta alasannya,
serta arsitektur View–State–Service dan wireframe tiga layar utama.

Status: **draf hari ke-1**, bagian *screenshot* aplikasi berjalan dan wireframe
final wajib dilengkapi bersama Anggota 2 sebelum laporan dikumpulkan.

---

## 1. Mengapa Flutter

CerdasCanteen adalah aplikasi pemesanan kantin kampus untuk mahasiswa. Ciri
kebutuhan utamanya:

| Kebutuhan | Konsekuensi teknis |
|---|---|
| Dipakai mahasiswa dengan HP Android **dan** iPhone | Satu basis kode untuk dua platform |
| Tampilan menu/kantin harus identik di semua perangkat | Rendering konsisten (tidak bergantung komponen OS) |
| Waktu pengerjaan tugas hanya 7 hari oleh 3 orang | Kecepatan iterasi UI paling penting |
| Perlu fitur native (notifikasi, info perangkat, kamera) | Harus ada akses plugin native yang matang |
| Tidak ada tim iOS & Android terpisah | Tidak mungkin menulis dua kode native sekaligus |

Kesimpulan: kebutuhan didominasi oleh **kecepatan pengembangan + konsistensi
UI**, bukan oleh performa ekstrem atau integrasi hardware yang sangat khusus.
Flutter paling cocok untuk profil kebutuhan ini.

### Alasan teknis yang lebih rinci

1. **Satu basis kode (single codebase).** `lib/` yang sama dikompilasi ke Android
   dan iOS. Perbaikan bug pada form login cukup sekali, bukan dua kali.
2. **Hot reload.** Perubahan UI terlihat dalam hitungan detik. Pada tugas dengan
   tenggat 7 hari, ini menghemat waktu paling besar dibanding rebuild native.
3. **Rendering konsisten.** Flutter menggambar sendiri lewat Skia/Impeller,
   sehingga tampilan kartu menu dan struk QR sama di Android 10 maupun iOS 17.
4. **Ekosistem widget kaya.** `qr_flutter` untuk struk QR, `flutter_local_notifications`
   untuk status pesanan, dan `device_info_plus` untuk info perangkat tersedia
   dengan dokumentasi lengkap — semuanya dipakai pada proyek ini.
5. **Dart + null safety.** Kesalahan `null` tertangkap saat kompilasi, bukan saat
   aplikasi dipakai di lapangan. Ini penting untuk data pesanan yang bisa kosong
   (`String? catatan`, keranjang kosong, status tidak dikenal).
6. **Biaya perawatan rendah.** Satu tim kecil tidak perlu memelihara dua proyek
   Gradle dan Xcode terpisah.

## 2. Perbandingan Flutter vs Native (Kotlin) vs React Native

| Aspek | Flutter | Native (Kotlin/Android) | React Native |
|---|---|---|---|
| Bahasa | Dart | Kotlin (Android), Swift (iOS) | JavaScript/TypeScript |
| Cakupan platform | Android + iOS dari 1 kode | Hanya Android; iOS perlu Swift terpisah | Android + iOS dari 1 kode |
| Performa | Sangat baik (kompilasi AOT, render sendiri) | Terbaik (akses penuh ke OS) | Baik, tetapi jembatan JS–native bisa jadi beban pada animasi/list panjang |
| Konsistensi UI antar platform | Tinggi (widget sendiri) | Rendah (Material vs Cupertino) | Sedang (bergantung komponen native per platform) |
| Waktu pengembangan untuk tim kecil | Cepat | Lambat (2 basis kode) | Cepat |
| Akses fitur native | Plugin resmi/komunitas; butuh penulisan channel untuk kasus khusus | Penuh, tanpa lapisan tambahan | Plugin komunitas; kualitas bervariasi |
| Ukuran artefak | Lebih besar (mesin Flutter disertakan) | Paling kecil | Kecil–sedang |
| Kurva belajar | Sedang (Dart mudah bagi yang paham OOP) | Sedang–tinggi | Rendah bila sudah paham JS/React |
| Ekosistem untuk kebutuhan proyek ini | Lengkap (QR, notifikasi, device info) | Lengkap tetapi harus ditulis dua kali | Lengkap, tetapi beberapa plugin perlu konfigurasi native manual |
| Risiko utama | Ukuran APK, plugin yang tertinggal versi | Waktu & tenaga berlipat | Debugging lintas jembatan (JS ↔ native) |

### Kapan alternatif lebih baik?

- **Native (Kotlin)** unggul bila aplikasi butuh integrasi mendalam dengan
  hardware (kamera profesional, BLE, sensor), animasi 120fps yang sangat
  kompleks, atau bila ukuran instalasi harus seminimal mungkin. Untuk
  CerdasCanteen, keunggulan ini tidak dipakai, sedangkan biayanya (dua basis
  kode) langsung terasa pada tenggat 7 hari.
- **React Native** unggul bila tim sudah kuat di JavaScript/React atau bila
  aplikasi akan berbagi logika dengan web React. Tim proyek ini memakai Dart/Flutter,
  sehingga keunggulan itu tidak relevan.

Keputusan akhir: **Flutter**, dengan alasan utama kecepatan pengembangan
satu basis kode dan konsistensi tampilan, sementara seluruh kebutuhan fitur
native proyek ini sudah tersedia sebagai plugin.

## 3. Platform yang dipakai dan alasannya

| Platform | Status | Alasan |
|---|---|---|
| **Android** (prioritas utama) | Target demo & pengujian fitur native | Mayoritas mahasiswa memakai Android; notifikasi lokal Android 13+ adalah skenario izin runtime yang paling representatif untuk dinilai |
| **iOS** | Didukung kode, tidak didemokan | Tidak ada perangkat Mac/iPhone di tim; kode izin notifikasi iOS tetap disiapkan agar aplikasi tidak crash |
| **Web (Chrome)** | Hanya untuk pengujian cepat & screenshot UI | Berguna memeriksa layout tanpa emulator; fitur notifikasi/info perangkat sengaja diberi jalur aman (`kIsWeb`) karena tidak didukung penuh |

Catatan bukti: *screenshot* aplikasi berjalan pada Android (emulator/perangkat
fisik) dan tampilan web akan ditempel pada bagian ini saat laporan final —
lihat folder `docs/screenshots/`.

## 4. Arsitektur View – State – Service

Aplikasi memakai pemisahan tiga lapis sederhana (tanpa state management
pihak ketiga agar mudah dinilai):

```
┌───────────────────────────────────────────────┐
│ VIEW  (lib/screens/**)                        │
│ - Hanya menggambar UI & meneruskan aksi       │
│ - Contoh: QrReceiptScreen, ProfileScreen       │
└───────────────┬───────────────────────────────┘
                │ membaca state / memanggil aksi
┌───────────────▼───────────────────────────────┐
│ STATE  (StatefulWidget / Future state)        │
│ - Menyimpan data yang ditampilkan             │
│ - Contoh: _deviceFuture di _ProfileScreenState│
│ - Menangani loading / error / data kosong     │
└───────────────┬───────────────────────────────┘
                │ meminta data / menjalankan logika
┌───────────────▼───────────────────────────────┐
│ SERVICE & UTIL (lib/services, lib/utils)      │
│ - NotificationService  (notifikasi lokal)     │
│ - DeviceService        (info perangkat)       │
│ - estimateWaitMinutes  (aturan bisnis murni)  │
│ - Validators, CheckoutRules (validasi form)   │
└───────────────┬───────────────────────────────┘
                │
        Plugin native / platform channel
```

Aturan yang dipegang:

1. **Logika bisnis tidak boleh berada di widget.** Rumus estimasi antrean ada di
   `lib/utils/queue_estimator.dart`, bukan di dalam `build()`. Konsekuensinya
   logika ini bisa diuji dengan `flutter test` tanpa emulator.
2. **Service tidak tahu tentang widget.** `NotificationService.showOrderStatus()`
   hanya butuh `OrderStatus`, sehingga bisa dipanggil dari alur checkout
   (Anggota 1) maupun dari halaman profil.
3. **Kegagalan fitur native tidak mematikan aplikasi.** Service menangkap
   exception dan mengembalikan `false`; UI menampilkan pesan ramah
   (lihat `_cobaNotifikasi()` saat izin ditolak).
4. **Dependency injection lewat konstruktor.** `ProfileScreen` menerima
   `DeviceService`, dan `DeviceService` sendiri menerima `DeviceSummaryLoader`,
   sehingga plugin native bisa diganti objek palsu saat pengujian.

## 5. Wireframe tiga layar utama

Wireframe teks di bawah adalah versi yang disepakati bersama Anggota 2.
Gambar wireframe (hasil Figma/sketsa) disimpan di `docs/wireframe/`.

### 5.1 Layar Menu Kantin (milik Anggota 1)

```
┌──────────────────────────────────┐
│ CerdasCanteen            🛒(2)   │
│ Kantin: Gedung A                 │
├──────────────────────────────────┤
│ [ Cari menu...               🔍 ]│
├──────────────────────────────────┤
│ ┌────────┐  ┌────────┐           │
│ │ Foto   │  │ Foto   │           │
│ │ Nasi   │  │ Mie    │           │
│ │ Goreng │  │ Ayam   │           │
│ │ Rp15rb │  │ Rp12rb │           │
│ │ [+ Tambah]           │         │
│ └────────┘  └────────┘           │
│ ┌────────┐  ┌────────┐           │
│ │ Es Teh │  │ Bakso  │           │
│ └────────┘  └────────┘           │
├──────────────────────────────────┤
│ [ Lihat Keranjang · Rp35.000 ]   │
└──────────────────────────────────┘
Navigasi bawah: Menu | Pesanan | Profil
```

### 5.2 Layar Struk Digital + QR (milik Anggota 3, sudah diimplementasikan)

```
┌──────────────────────────────────┐
│ ← Struk Digital                  │
├──────────────────────────────────┤
│            CerdasCanteen         │
│        Struk Pesanan CC-2024     │
│        ┌──────────────────┐      │
│        │  ▓▓ ▓ ▓▓ ▓ ▓▓    │      │
│        │  ▓  QR  ▓  ▓     │      │
│        │  ▓▓ ▓ ▓▓ ▓ ▓▓    │      │
│        └──────────────────┘      │
│  Tunjukkan QR ini ke kasir saat  │
│  mengambil pesanan.              │
├──────────────────────────────────┤
│ ⏱ Estimasi waktu tunggu          │
│    15 menit                      │
├──────────────────────────────────┤
│ Nasi Goreng   2 x Rp15.000  Rp30.000
│ Es Teh        1 x Rp5.000    Rp5.000
│ ──────────────────────────────── │
│ Total                      Rp35.000
│ 🍽 Status Pesanan  [Diproses]     │
│ 👥 Antrean di depan    3 orang    │
└──────────────────────────────────┘
```

### 5.3 Layar Profil + Info Perangkat (milik Anggota 3, sudah diimplementasikan)

```
┌──────────────────────────────────┐
│ Profil Saya                 🔄   │
├──────────────────────────────────┤
│ (A) Mahasiswa CerdasCanteen      │
│     NIM 2210512000               │
├──────────────────────────────────┤
│ Informasi Perangkat              │
│ Dibaca langsung dari perangkat   │
│ ──────────────────────────────── │
│ Perangkat     samsung SM-A525F   │
│ Merek                    samsung │
│ Versi Android  Android 13 (API 33)│
│ Login terakhir  05/01/2026 09:07 │
├──────────────────────────────────┤
│ Notifikasi Pesanan               │
│ [ 🔔 Coba Notifikasi "Siap Diambil" ]
├──────────────────────────────────┤
│ Total belanja contoh: Rp48.500    │
└──────────────────────────────────┘
```

## 6. Risiko dan mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Plugin notifikasi tidak mendukung versi Flutter terbaru | Fitur native gagal | Versi plugin dikunci di `pubspec.yaml`; kegagalan ditangkap dan dilaporkan ke pengguna |
| `flutter_local_notifications` butuh desugaring | Build Android gagal | `isCoreLibraryDesugaringEnabled = true` + dependency `desugar_jdk_libs` sudah ditambahkan |
| Izin notifikasi ditolak pengguna | Notifikasi tidak muncul | Aplikasi tetap berjalan; muncul dialog penjelasan, bukan crash |
| Kode anggota lain belum selesai saat integrasi | Test gagal massal | Test dijalankan per file (`flutter test test/xxx_test.dart`) |
| Data perangkat tidak terbaca (mis. di web) | Halaman profil error | `DeviceService` menangkap error dan menampilkan "Tidak diketahui" |
