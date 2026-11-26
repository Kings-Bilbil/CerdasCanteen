# Dokumentasi Teknis — Anggota 1 (Lead Developer)
**Proyek:** CerdasCanteen (Kelompok 1) — Aplikasi Pemesanan Makanan Kantin Kampus  
**Mata Kuliah:** Pengembangan Aplikasi Perangkat Bergerak (A) — Prodi Sistem Informasi FMIPA UNTAN

---

## 1. Platform Kerja & Arsitektur Aplikasi (Tugas 1)

### A. Pemilihan Platform Kerja: FlutLab.io
Kelompok 1 memilih **FlutLab.io** (cloud-based Flutter IDE dengan SDK Flutter 3.41) sebagai platform pengembangan utama dengan pertimbangan berikut:
1. **Efisiensi Spesifikasi Perangkat:** Tidak membutuhkan instalasi Android Studio, Android SDK, maupun emulator lokal yang berat sehingga seluruh anggota dapat langsung memulai pengembangan sejak Hari 1.
2. **Kolaborasi & Integrasi GitHub:** Mendukung *Source Control* terintegrasi ke repository GitHub kelompok (*branching* `anggota-1`, `anggota-2`, `anggota-3` dan *commit* merata per anggota) serta *cloud build* untuk pratinjau Web dan Android APK.
3. **Konsistensi Versi SDK:** Seluruh anggota bekerja pada versi Flutter dan Dart yang sama sehingga meminimalkan konflik dependensi antar perangkat.

### B. Rancangan Arsitektur Aplikasi (`View – State – Service`)
CerdasCanteen menggunakan pola arsitektur berlapis **`View – State (Provider) – Service`** untuk memisahkan antarmuka pengguna, manajemen state, dan akses data:

```text
[ View / Screens & Widgets ]
   (Login, Register, MainNavigation, MenuDetail, Cart, Checkout, History, Profile)
             │  baca state (Consumer / Selector) & kirim event
             ▼
[ State / Providers (ChangeNotifier + MultiProvider) ]
   (AuthProvider, CartProvider)
             │  panggil fungsi asinkron (Future / async-await)
             ▼
[ Services & Data Layer ]
   ├── AuthService         -> REST API PHP + MySQL (register/login)
   ├── ApiService          -> REST API publik (daftar menu JSON - Anggota 2)
   ├── DbHelper            -> SQLite lokal (riwayat transaksi CRUD - Anggota 2)
   ├── PrefsService        -> SharedPreferences (pengaturan & tema - Anggota 2)
   └── NotificationService -> Local Notification & fitur perangkat (Anggota 3)
             │
             ▼
[ Models ]
   (UserModel, CanteenMenu, CartItem, OrderRecord)
```

---

## 2. Navigasi & Interaksi Antar Halaman (Tugas 5)
* **Named Routes & Route Guard:** Didefinisikan secara terpusat di `lib/routes/app_routes.dart` (`/login`, `/register`, `/main`, `/detail`, `/cart`, `/checkout`).
* **Pengantaran Data (`Navigator.push`):** Saat pengguna memilih kartu menu pada halaman utama, aplikasi mengirimkan objek `CanteenMenu` ke `MenuDetailScreen` melalui `Navigator.push` (`MaterialPageRoute`).
* **Navigasi Multi-Halaman (`BottomNavigationBar`):** Menggunakan `MainNavigationScreen` dengan 4 tab utama (`Menu`, `Keranjang`, `Riwayat`, `Profil`) dilengkapi `IndexedStack` agar posisi halaman terjaga saat berpindah tab.

---

## 3. Penjelasan Manajemen State: Kapan `setState` Cukup dan Kapan Tidak? (Tugas 6 & Tugas 7)

### Kapan `setState` Cukup Digunakan?
`setState` cukup dan ideal digunakan untuk **ephemeral state (state lokal)** yang hanya memengaruhi satu widget/layar dan tidak dibutuhkan oleh halaman lain. Pada CerdasCanteen, `setState` diterapkan untuk:
* Toggle sembunyikan/tampilkan password (`_obscurePassword`) dan switch *Ingat Sesi* pada `LoginScreen` & `RegisterScreen`.
* Tombol favorit (`_isFavorite`), counter jumlah porsi (`_qty`), switch *Bungkus / Take-Away* (`_takeAway`), switch *Ekstra Pedas* (`_ekstraPedas`), dan validasi form catatan (`GlobalKey<FormState>`) pada `MenuDetailScreen`.
* Pilihan tab aktif `BottomNavigationBar` (`_selectedIndex`) pada `MainNavigationScreen` dan pilihan metode pembayaran (`_metodeBayar`) pada `CheckoutScreen`.

### Kapan `setState` TIDAK Cukup (Harus Menggunakan `Provider`)?
`setState` menjadi tidak efektif dan rawan ketidaksinkronan data ketika mengelola **app state (state global)** yang diakses oleh banyak halaman sekaligus. Jika tetap dipaksakan menggunakan `setState`, pengembang harus meneruskan data dan callback secara berlapis (*prop drilling*) serta memicu rebuild berlebihan.

Pada CerdasCanteen, state global dikelola menggunakan **`MultiProvider` + `ChangeNotifier`** dengan **`Consumer`** dan **`Selector`**:
1. **`CartProvider`**: Mengelola daftar item keranjang, jumlah total item (badge pada `AppBar`, `BottomNavigationBar`, dan `MenuDetailScreen`), serta total harga pada `CartScreen` dan `CheckoutScreen` agar selalu sinkron saat berpindah halaman.
2. **`AuthProvider`**: Mengelola status autentikasi (`isAuthenticated`) dan data akun mahasiswa (`UserModel`) yang dibutuhkan oleh proteksi rute, halaman Checkout, dan halaman Profil.

---

## 4. Pemrograman Asinkron & Perilaku Event Loop (Tugas 8)
Dart bekerja menggunakan model **single-threaded Event Loop** (satu thread utama yang mengeksekusi *microtask queue* dan *event queue*).

Berdasarkan pengujian pada `dart_basics/tugas8_sync_vs_async.dart`:
* **Eksekusi Sinkron (Blocking — loop 5 detik):** Fungsi `prosesSinkron()` menahan thread utama selama 5 detik penuh. Event Loop tidak dapat menjalankan perintah berikutnya (`[2]`) ataupun merespons sentuhan pengguna hingga loop berakhir, sehingga aplikasi terasa macet (*freeze*).
* **Eksekusi Asinkron (Non-Blocking — `Future.delayed` + `async/await`):** Ketika `prosesAsinkron()` dipanggil, timer 5 detik didaftarkan ke *Event Queue* sementara thread utama langsung melanjutkan eksekusi baris `[2]` dan `[3]` tanpa menunggu. Setelah 5 detik selesai, callback dilanjutkan hingga baris `[4]`.
* **Implementasi pada Aplikasi:** Proses checkout (`CartProvider.checkout()`) dan autentikasi (`AuthService`) menerapkan `Future`, `async/await`, dan `try-catch` lengkap dengan `CircularProgressIndicator` (*loading indicator*) serta tampilan *error state* (offline/timeout) beserta tombol **Coba Lagi**.

---

## 5. Sistem Autentikasi Pengguna dengan MySQL (Tugas 11)
* **Backend PHP + MySQL (`backend/`):** Terdiri atas `database.sql` (tabel `users` dan `orders`), `config.php` (koneksi PDO MySQL + header CORS), `register.php`, dan `login.php`.
* **Keamanan Password:** `register.php` mengenkripsi password mahasiswa dengan algoritma **BCRYPT** (`password_hash($password, PASSWORD_BCRYPT)`) sebelum disimpan ke kolom `password_hash`, sehingga password tidak pernah tersimpan dalam bentuk teks biasa. Saat login, `login.php` memvalidasi hash menggunakan `password_verify()`.
* **Proteksi Halaman (Route Guard):** Pada `lib/main.dart` dan `lib/routes/app_routes.dart`, jika pengguna belum login (`isAuthenticated == false`) lalu mengakses halaman privat, sistem otomatis mengarahkan kembali (*redirect*) ke `LoginScreen`. Saat menekan **Logout**, sesi pengguna dan keranjang dibersihkan lalu pengguna diarahkan ke `/login`.