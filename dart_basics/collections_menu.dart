// dart_basics/collections_menu.dart
// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls

// Program Dart Console — Tugas 2b (Koleksi List & Map)
// Aplikasi: CerdasCanteen (Pemesanan Makanan Kantin Kampus)
// Penulis: Anggota 2 (UI/UX & Data)

/// Helper untuk memformat angka integer menjadi format mata uang Rupiah.
/// Contoh: 12000 -> "Rp12.000"
String formatRupiah(int nominal) {
  final String angka = nominal.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < angka.length; i++) {
    final int posisiDariBelakang = angka.length - i;
    buffer.write(angka[i]);
    if (posisiDariBelakang > 1 && posisiDariBelakang % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp${buffer.toString()}';
}

void main() {
  // 1. Data 12 menu kantin kampus (minimal 10 menu, 3 kategori: Makanan, Minuman, Snack)
  final List<Map<String, dynamic>> daftarMenu = [
    {'nama': 'Nasi Goreng Telur', 'harga': 12000, 'kategori': 'Makanan'},
    {'nama': 'Ayam Geprek Sambal Matah', 'harga': 15000, 'kategori': 'Makanan'},
    {'nama': 'Ayam Penyet Lalapan', 'harga': 14000, 'kategori': 'Makanan'},
    {'nama': 'Mie Goreng Spesial', 'harga': 11000, 'kategori': 'Makanan'},
    {'nama': 'Soto Ayam Kampung', 'harga': 18000, 'kategori': 'Makanan'},
    {'nama': 'Es Teh Manis', 'harga': 5000, 'kategori': 'Minuman'},
    {'nama': 'Es Jeruk Peras', 'harga': 7000, 'kategori': 'Minuman'},
    {'nama': 'Kopi Susu Gula Aren', 'harga': 13000, 'kategori': 'Minuman'},
    {'nama': 'Jus Alpukat Cokelat', 'harga': 16000, 'kategori': 'Minuman'},
    {'nama': 'Gorengan Mix (3 pcs)', 'harga': 6000, 'kategori': 'Snack'},
    {'nama': 'Risoles Mayo (2 pcs)', 'harga': 8000, 'kategori': 'Snack'},
    {'nama': 'Pisang Goreng Keju', 'harga': 10000, 'kategori': 'Snack'},
  ];

  const String garis = '============================================================';
  const String subGaris = '------------------------------------------------------------';

  print(garis);
  print('          CERDASCANTEEN - REKAP MENU & PESANAN KANTIN       ');
  print(garis);

  // 2. Menampilkan seluruh daftar menu menggunakan forEach
  print('\n[1] DAFTAR MENU KANTIN (${daftarMenu.length} ITEM)');
  print(subGaris);
  print('${'No'.padRight(4)}${'Nama Menu'.padRight(27)}${'Kategori'.padRight(11)}${'Harga'.padLeft(10)}');
  print(subGaris);

  daftarMenu.asMap().forEach((int index, Map<String, dynamic> menu) {
    final String nomor = '${index + 1}.'.padRight(4);
    final String nama = (menu['nama'] as String).padRight(27);
    final String kategori = (menu['kategori'] as String).padRight(11);
    final String harga = formatRupiah(menu['harga'] as int).padLeft(10);
    print('$nomor$nama$kategori$harga');
  });

  // 3. Mengambil daftar kategori unik menggunakan map() dan toSet()
  final List<String> daftarKategori = daftarMenu
      .map((Map<String, dynamic> item) => item['kategori'] as String)
      .toSet()
      .toList();

  // 4. Rekap pesanan per kategori memakai Map<String, Map<String, int>>
  //    Menggunakan where() untuk menyaring per kategori dan fold() untuk menjumlahkan harga
  final Map<String, Map<String, int>> rekapPerKategori = {};

  daftarKategori.forEach((String kategori) {
    // Saring semua item yang termasuk dalam kategori saat ini
    final List<Map<String, dynamic>> itemKategori = daftarMenu
        .where((Map<String, dynamic> item) => item['kategori'] == kategori)
        .toList();

    // Hitung total harga pada kategori tersebut memakai fold()
    final int totalHargaKategori = itemKategori.fold<int>(
      0,
      (int akumulator, Map<String, dynamic> item) =>
          akumulator + (item['harga'] as int),
    );

    // Simpan jumlah item dan total harga ke dalam Map rekap
    rekapPerKategori[kategori] = {
      'jumlahItem': itemKategori.length,
      'totalHarga': totalHargaKategori,
    };
  });

  // Hitung total keseluruhan harga semua pesanan menggunakan fold()
  final int totalKeseluruhan = daftarMenu.fold<int>(
    0,
    (int total, Map<String, dynamic> item) => total + (item['harga'] as int),
  );

  // Tampilkan rekap per kategori menggunakan forEach()
  print('\n[2] REKAP PESANAN PER KATEGORI (Map + where + map + fold + forEach)');
  print(subGaris);
  print('${'Kategori'.padRight(15)}${'Jumlah Item'.padRight(15)}${'Total Harga'.padLeft(15)}');
  print(subGaris);

  rekapPerKategori.forEach((String kategori, Map<String, int> data) {
    final String labelKategori = kategori.padRight(15);
    final String labelJumlah = '${data['jumlahItem']} item'.padRight(15);
    final String labelTotal = formatRupiah(data['totalHarga'] ?? 0).padLeft(15);
    print('$labelKategori$labelJumlah$labelTotal');
  });

  print(subGaris);
  print(
    '${'TOTAL SEMUA'.padRight(15)}'
    '${'${daftarMenu.length} item'.padRight(15)}'
    '${formatRupiah(totalKeseluruhan).padLeft(15)}',
  );

  // 5. Analisis statistik harga: menu termahal, menu termurah, dan rata-rata harga
  //    Mencari menu termahal menggunakan fold()
  final Map<String, dynamic> menuTermahal = daftarMenu.fold<Map<String, dynamic>>(
    daftarMenu.first,
    (Map<String, dynamic> termahal, Map<String, dynamic> item) =>
        (item['harga'] as int) > (termahal['harga'] as int) ? item : termahal,
  );

  // Mencari menu termurah menggunakan fold()
  final Map<String, dynamic> menuTermurah = daftarMenu.fold<Map<String, dynamic>>(
    daftarMenu.first,
    (Map<String, dynamic> termurah, Map<String, dynamic> item) =>
        (item['harga'] as int) < (termurah['harga'] as int) ? item : termurah,
  );

  // Menghitung rata-rata harga seluruh menu
  final double rataRataHarga = totalKeseluruhan / daftarMenu.length;

  print('\n[3] STATISTIK HARGA MENU');
  print(subGaris);
  print(
    'Menu Termahal   : ${menuTermahal['nama']} '
    '(${formatRupiah(menuTermahal['harga'] as int)} - ${menuTermahal['kategori']})',
  );
  print(
    'Menu Termurah   : ${menuTermurah['nama']} '
    '(${formatRupiah(menuTermurah['harga'] as int)} - ${menuTermurah['kategori']})',
  );
  print('Total Harga     : ${formatRupiah(totalKeseluruhan)}');
  print('Rata-rata Harga : ${formatRupiah(rataRataHarga.round())}');

  // 6. Contoh filter menu hemat (<= Rp10.000) menggunakan where() dan map()
  final List<String> menuHemat = daftarMenu
      .where((Map<String, dynamic> item) => (item['harga'] as int) <= 10000)
      .map((Map<String, dynamic> item) =>
          '${item['nama']} (${formatRupiah(item['harga'] as int)})')
      .toList();

  print('\n[4] MENU HEMAT MAHASISWA (<= Rp10.000)');
  print(subGaris);
  menuHemat.asMap().forEach((int index, String label) {
    print('${index + 1}. $label');
  });

  // 7. Hasil pengurutan (sort) harga dari termurah ke termahal
  //    Menggunakan List.from() agar urutan list asli (daftarMenu) tidak berubah
  final List<Map<String, dynamic>> menuUrutTermurah =
      List<Map<String, dynamic>>.from(daftarMenu)
        ..sort((a, b) => (a['harga'] as int).compareTo(b['harga'] as int));

  print('\n[5] HASIL SORT HARGA (TERMURAH -> TERMAHAL)');
  print(subGaris);
  print('${'No'.padRight(4)}${'Nama Menu'.padRight(27)}${'Kategori'.padRight(11)}${'Harga'.padLeft(10)}');
  print(subGaris);

  menuUrutTermurah.asMap().forEach((int index, Map<String, dynamic> menu) {
    final String nomor = '${index + 1}.'.padRight(4);
    final String nama = (menu['nama'] as String).padRight(27);
    final String kategori = (menu['kategori'] as String).padRight(11);
    final String harga = formatRupiah(menu['harga'] as int).padLeft(10);
    print('$nomor$nama$kategori$harga');
  });

  // 8. Hasil pengurutan (sort) harga dari termahal ke termurah
  final List<Map<String, dynamic>> menuUrutTermahal =
      List<Map<String, dynamic>>.from(daftarMenu)
        ..sort((a, b) => (b['harga'] as int).compareTo(a['harga'] as int));

  print('\n[6] HASIL SORT HARGA (TERMAHAL -> TERMURAH)');
  print(subGaris);
  print('${'No'.padRight(4)}${'Nama Menu'.padRight(27)}${'Kategori'.padRight(11)}${'Harga'.padLeft(10)}');
  print(subGaris);

  menuUrutTermahal.asMap().forEach((int index, Map<String, dynamic> menu) {
    final String nomor = '${index + 1}.'.padRight(4);
    final String nama = (menu['nama'] as String).padRight(27);
    final String kategori = (menu['kategori'] as String).padRight(11);
    final String harga = formatRupiah(menu['harga'] as int).padLeft(10);
    print('$nomor$nama$kategori$harga');
  });

  print('\n$garis');
  print('                 PROGRAM SELESAI DIJALANKAN                 ');
  print(garis);
}
