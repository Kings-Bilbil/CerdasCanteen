# Tugas 14 — Nilai Bisnis QR Struk & Estimasi Antrean

## 1. Fitur yang dinilai

1. **Struk digital ber-QR** (layar struk; kontrak di `docs/Variabel.md` §9) —
   menampilkan kode pesanan, rincian item, total, status, dan estimasi tunggu
   dalam satu QR. Payload QR diuji lewat `QrReceiptScreen.qrData` pada widget
   test yang diparkir di `docs/rencana_test/`.
2. **Estimasi waktu antrean** (`lib/utils/queue_estimator.dart`) — perhitungan
   `(antrean × 3) + (item × 2)` menit, disajikan di layar struk dan dipakai
   pada notifikasi "Siap Diambil". Modul ini aktif dan teruji di repo.

## 2. Manfaat bagi mahasiswa

| Manfaat | Penjelasan | Bagaimana fitur mewujudkannya |
|---|---|---|
| Hemat waktu | Tidak perlu menunggu berdiri di depan konter | Estimasi memberi tahu kapan harus kembali; notifikasi memanggil saat siap |
| Kepastian | Menghilangkan "kira-kira berapa lama lagi?" | Angka menit konkret (mis. "15 menit") menggantikan terkaan |
| Bisa multitasking | Bisa belajar/ke perpustakaan selama menunggu | Estimasi + notifikasi membuat mahasiswa tidak terikat lokasi |
| Tanpa kertas | Struk tidak hilang/tercecer | QR digital selalu ada di HP |
| Pengambilan lebih cepat | Kasir memindai QR, bukan mengetik pesanan | Payload QR memuat ID, jumlah item, total, estimasi, status |
| Transparansi harga | Rincian item dan total terlihat sebelum bayar | Struk menampilkan subtotal tiap item dan total |
| Rasa aman | Kesalahan pesanan mudah ditunjukkan | QR berisi data yang bisa dicocokkan kasir |

## 3. Manfaat bagi kantin

| Manfaat | Penjelasan | Dampak terukur (target) |
|---|---|---|
| Antrean fisik lebih pendek | Mahasiswa datang saat pesanan hampir siap | Antrean di konter turun dari 10+ menjadi 2–3 orang |
| Ruang tunggu tidak penuh | Beban visual & keramaian berkurang | Kenyamanan pembeli lain naik |
| Pelayanan lebih cepat | Verifikasi lewat scan QR, bukan tanya-jawab | Waktu serah-terima turun (target 30 detik/pesanan) |
| Prediksi beban kerja | Data estimasi membantu menambah petugas di jam sibuk | Keputusan operasional berbasis data, bukan feeling |
| Pengurangan kesalahan pesanan | Data pesanan tercatat digital | Komplain "salah pesanan" turun |
| Hemat biaya cetak | Tidak ada struk kertas | Penghematan kertas & printer thermal |
| Data untuk evaluasi menu | Item yang sering dipesan terlihat dari data pesanan | Menu lambat dijual bisa dievaluasi |

**Ringkasnya:** nilai bagi mahasiswa adalah **waktu dan kepastian**, nilai bagi
kantin adalah **arus pelanggan yang lebih terkendali dan proses serah-terima
yang lebih cepat**.

## 4. Keberlanjutan (sustainability)

Fitur ini bukan sekadar tugas kuliah; ada beberapa jalur agar terus hidup dan
membiayai dirinya.

### 4.1 Model pendapatan

| Model | Mekanisme | Kelebihan | Risiko |
|---|---|---|---|
| **Komisi transaksi** | 1–2% dari setiap pesanan yang dibayar lewat aplikasi | Pendapatan tumbuh seiring volume; adil karena kantin untung | Kantin kecil bisa keberatan; perlu gratis untuk 100 pesanan pertama |
| **Langganan kantin** | Rp50.000–100.000/bulan per kantin untuk fitur analitik & prioritas tampil | Pendapatan berulang dan stabil | Butuh nilai analitik yang benar-benar dipakai |
| **Iklan menu** | Menu/kantin berbayar tampil di urutan atas atau jadi "Rekomendasi Hari Ini" | Tidak membebani transaksi | Bisa mengganggu pengalaman bila berlebihan |
| **Iklan pihak ketiga** | Banner produk kampus (alat tulis, laundry, bimbel) | Tambahan pendapatan tanpa mengubah alur | Butuh basis pengguna besar dulu |

Rekomendasi tahap awal: **komisi kecil + gratis untuk kantin pertama**, lalu
naik ke langganan ketika data analitik sudah terbukti berguna.

### 4.2 Rencana pengembangan (roadmap)

| Fase | Fokus | Fitur kunci |
|---|---|---|
| 1 (sekarang) | Inti pemesanan | Menu, keranjang, checkout, struk QR, estimasi, notifikasi |
| 2 | Pembayaran | QRIS / e-wallet, status pembayaran di struk |
| 3 | Operasional kantin | Dashboard pesanan masuk, tandai "Diproses"/"Siap Diambil", analitik penjualan |
| 4 | Personalisasi | Riwayat pesanan, menu favorit, rekomendasi berbasis riwayat |
| 5 | Skala | Multi-kantin, multi-kampus, kalibrasi estimasi per kantin dari data nyata |

### 4.3 Aspek yang menjaga keberlanjutan teknis

1. **Kalibrasi estimasi berbasis data.** Konstanta `minutesPerQueue` /
   `minutesPerItem` sudah dipisah sebagai konstanta bernama sehingga bisa
   diubah tanpa menyentuh logika — prasyarat untuk kalibrasi otomatis nanti.
2. **Logika bisnis terpisah dari UI.** `estimateWaitMinutes`, `Validators`, dan
   `CheckoutRules` adalah fungsi murni, sehingga bisa dipakai ulang oleh backend
   atau aplikasi kasir tanpa menyalin kode UI.
3. **QR sebagai kontrak data.** Payload QR berisi teks terstruktur
   (`ID`, `ITEM`, `TOTAL`, `EST`, `STATUS`) sehingga aplikasi kasir mana pun bisa
   memverifikasi tanpa bergantung pada aplikasi mahasiswa.
4. **Uji regresi.** 53 test dan dua siklus TDD menjaga agar perubahan aturan
   bisnis (mis. konstanta antrean) tidak merusak fitur lain.
5. **Ketahanan terhadap kegagalan.** Izin notifikasi ditolak atau info perangkat
   tidak terbaca tidak menghentikan pemesanan — penting untuk adopsi di
   perangkat beragam milik mahasiswa.

### 4.4 Dampak yang ingin diukur setelah rilis

- Rata-rata waktu tunggu: dari 10,5 menit (data manual) menjadi ≤6 menit.
- Jumlah mahasiswa yang menunggu di depan konter: dari 10+ menjadi ≤3.
- Tingkat penggunaan struk digital: ≥80% pesanan diverifikasi lewat QR.
- Retensi kantin: ≥70% kantin masih aktif setelah 3 bulan.

## 5. Kesimpulan nilai bisnis

QR struk dan estimasi antrean terlihat sebagai fitur kecil, tetapi keduanya
menyerang masalah inti kantin kampus: **antrean yang padat pada jam sibuk dan
ketidakpastian waktu tunggu**. Bagi mahasiswa, keduanya mengubah "menunggu
tanpa kepastian" menjadi "menunggu dengan jadwal". Bagi kantin, keduanya
mengubah arus pelanggan yang menumpuk menjadi arus yang bisa dikelola. Dengan
model komisi dan langganan yang ringan, fitur ini punya jalur pendapatan yang
jelas dan bisa dikembangkan bertahap tanpa membongkar arsitektur yang sudah ada.
