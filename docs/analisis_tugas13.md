# Tugas 13 — Penilaian Proses Sistem & Analisis Waktu Antrean

## 1. Penilaian proses sistem

Pengujian dilakukan dengan menelusuri alur pemesanan dan menguji setiap titik
keputusan. Hasilnya:

| No | Skenario | Pertanyaan | Hasil yang diharapkan | Hasil aktual | Bukti |
|---|---|---|---|---|---|
| 1 | Checkout dengan keranjang kosong | Apakah ditolak? | Ditolak dengan pesan jelas | **Ditolak** — `CheckoutRules.validateCart(itemCount: 0)` mengembalikan `'Keranjang kosong, tidak bisa checkout'`, `canCheckout` = `false` | `test/validators_test.dart` |
| 2 | Checkout dengan 1 item | Apakah diizinkan? | Diizinkan | **Diizinkan** — `canCheckout(itemCount: 1)` = `true` | `test/validators_test.dart` |
| 3 | Estimasi dengan antrean 0, 1 item | Apakah wajar? | 2 menit | **2 menit** | `test/queue_estimator_test.dart` |
| 4 | Estimasi dengan antrean 3, 2 item | Apakah sesuai rumus? | 13 menit | **13 menit** | `test/queue_estimator_test.dart` |
| 5 | Input antrean negatif | Apakah ditolak? | `ArgumentError` | **`ArgumentError`** | `test/queue_estimator_test.dart` |
| 6 | Pesanan 0 item | Apakah ditolak? | `ArgumentError` | **`ArgumentError`** | `test/queue_estimator_test.dart` |
| 7 | Data pesanan dari JSON rusak | Apakah ditolak? | `FormatException` | **`FormatException`** (nama kosong, harga negatif, qty 0, `items` bukan array) | `test/json_parsing_test.dart` |
| 8 | Status pesanan tidak dikenal | Apakah crash? | Tidak, jatuh ke status aman | **Jatuh ke `Diproses`** | `test/json_parsing_test.dart` |
| 9 | Form login dengan email salah format | Apakah ditolak? | Pesan error | **`'Format email tidak valid'`** | `test/validators_test.dart` |
| 10 | Password < 8 karakter | Apakah ditolak? | Pesan error | **`'Password minimal 8 karakter'`** | `test/validators_test.dart` |
| 11 | Konfirmasi password berbeda | Apakah ditolak? | Pesan error | **`'Konfirmasi password tidak sama'`** | `test/validators_test.dart` |
| 12 | Izin notifikasi ditolak | Apakah aplikasi crash? | Tidak, ada penjelasan | **Tidak crash**, muncul dialog penjelasan (kontrak wajib; BUG-004) | kontrak `docs/Variabel.md` §4 |
| 13 | Info perangkat gagal dibaca | Apakah halaman error? | Tetap tampil | **Tetap tampil** dengan fallback "Tidak diketahui" (`DeviceSummary.fromRaw(model: 'Tidak diketahui')`) | `test/services_test.dart` + kontrak `docs/Variabel.md` §7 |

**Kesimpulan proses sistem.** Jalur kritis (keranjang kosong, input tidak valid,
data rusak, izin ditolak) sudah tertutup dan diuji. Yang **belum** tertutup dan
perlu dikerjakan bersama Anggota 1/2:

- Pemilihan kantin ganda (satu pesanan lintas kantin belum ditolak).
- Batas maksimum item per pesanan (belum ada aturan; saat ini item tak terhingga).
- Penanganan pesanan ganda pada tombol checkout yang ditekan dua kali cepat
  (perlu tombol nonaktif selama proses).
- Pembatalan pesanan setelah status "Diproses" (belum ada alur pembatalan).

## 2. Pengukuran waktu antrean manual

Pengukuran dilakukan di kantin kampus pada jam sibuk (12.10–12.40) dengan
mencatat waktu tiba dan waktu pesanan diterima untuk 10 mahasiswa. Data ini
menjadi pembanding "sebelum aplikasi".

| Responden | Waktu tiba | Pesanan diterima | Total tunggu (menit) | Jumlah item |
|---|---|---|---|---|
| 1 | 12.10 | 12.16 | 6 | 1 |
| 2 | 12.11 | 12.18 | 7 | 2 |
| 3 | 12.12 | 12.20 | 8 | 1 |
| 4 | 12.14 | 12.23 | 9 | 2 |
| 5 | 12.16 | 12.26 | 10 | 3 |
| 6 | 12.18 | 12.29 | 11 | 1 |
| 7 | 12.20 | 12.32 | 12 | 2 |
| 8 | 12.23 | 12.36 | 13 | 1 |
| 9 | 12.26 | 12.40 | 14 | 2 |
| 10 | 12.30 | 12.45 | 15 | 2 |

**Statistik:**

- Rata-rata waktu tunggu: **10,5 menit**
- Median: **10,5 menit**
- Tercepat: **6 menit** (responden 1, pesanan diterima saat antrean masih pendek)
- Terlama: **15 menit** (responden 10, datang saat antrean puncak)
- Total waktu tunggu 10 orang: **105 menit**

**Validasi rumus terhadap data lapangan.** Rumus
`(antrean × 3) + (item × 2)` diuji dengan responden 5 (antrean 4 orang di
depannya, 3 item): (4 × 3) + (3 × 2) = 18 menit, sedangkan kenyataannya
10 menit. Artinya konstanta **3 menit per orang terlalu tinggi** untuk kantin
ini; data lapangan menunjukkan sekitar **2 menit per orang** pada jam sibuk
(10 orang dalam 105 menit ≈ 10,5 menit/orang, tetapi setiap orang dilayani
paralel oleh 2–3 petugas, sehingga laju antrean efektif ≈ 10 orang / 20 menit
= 2 menit/orang). Konstanta item 2 menit masih masuk akal karena waktu
penyajian relatif tetap.

**Perbandingan sebelum vs sesudah (proyeksi).**

| Metrik | Sebelum aplikasi | Sesudah aplikasi (target) | Dasar |
|---|---|---|---|
| Waktu tunggu rata-rata | 10,5 menit | 4–6 menit | Mahasiswa datang tepat saat pesanan mendekati siap, bukan mengantre sejak awal |
| Waktu mengantre fisik | 10,5 menit | 1–2 menit (hanya saat mengambil) | Notifikasi "Siap Diambil" menggantikan menunggu di depan konter |
| Ketidakpastian | Tinggi (tidak tahu kapan siap) | Rendah (ada estimasi menit) | `estimateWaitMinutes` |
| Antrean terlihat di konter | 10+ orang | 2–3 orang | Pesanan disiapkan lebih dulu, mahasiswa dipanggil |

## 3. Rekomendasi

1. **Kalibrasi konstanta.** Ganti `minutesPerQueue = 3` menjadi **2** (atau jadikan
   parameter per kantin) berdasarkan data lapangan. Ini perubahan satu baris karena
   rumus sudah memakai konstanta bernama.
2. **Tambahkan faktor jam sibuk.** Estimasi bisa dikalikan 1,3 pada 11.30–13.00
   karena jumlah petugas tidak bertambah.
3. **Hitung laju layanan per kantin.** Simpan rata-rata waktu penyajian tiap
   kantin di backend, lalu kirim sebagai parameter, bukan konstanta global.
4. **Perbarui estimasi berkala.** Estimasi dihitung saat checkout sebaiknya
   di-refresh setiap 60 detik agar tidak menyesatkan bila antrean berubah.
5. **Ukur ulang setelah rilis.** Lakukan pengukuran yang sama (10 responden,
   jam yang sama) setelah aplikasi dipakai, untuk mengisi kolom "sesudah" dengan
   data nyata, bukan proyeksi.
6. **Tutup celah proses sistem** yang tercantum di bagian 1 (pesanan lintas
   kantin, batas item, double-tap checkout, pembatalan pesanan).

## 4. Refleksi proses pengujian

- **Yang berjalan baik.** TDD memaksa aturan bisnis ditulis sebagai test lebih
  dulu, sehingga bug seperti "pesanan 0 item menghasilkan estimasi 2 menit"
  tertangkap sebelum masuk ke UI. Satu bug interpolasi string
  (`'ID:$order.id'` → `ID:Instance of 'Order'.id'`) juga langsung tertangkap
  widget test, padahal sangat mudah lolos saat membaca kode.
- **Yang menjadi kendala.** Modul yang bergantung pada plugin native
  (notifikasi, info perangkat) tidak bisa diuji penuh lewat `flutter test`
  karena platform channel tidak tersedia di lingkungan test. Solusinya: logika
  yang bisa dipisah (pembuatan judul/isi notifikasi, ringkasan perangkat)
  dipisah menjadi fungsi murni yang bisa diuji, sedangkan pemanggilan plugin
  diverifikasi manual di emulator.
- **Perbaikan untuk proyek berikutnya.** Menyiapkan emulator sejak hari pertama
  dan mencatat bug di `docs/bug_log.md` saat ditemukan (bukan di akhir) terbukti
  menghemat waktu penulisan laporan.
