// ignore_for_file: avoid_print
// Tugas 2a (Sub-CPMK0531) — Konsep OOP: Class, Inheritance, & Polymorphism
// Domain: CerdasCanteen (Aplikasi Pemesanan Makanan Kantin Kampus)

String formatRupiah(int nominal) {
  final str = nominal.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final posisiDariBelakang = str.length - i;
    buffer.write(str[i]);
    if (posisiDariBelakang > 1 && posisiDariBelakang % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp$buffer';
}

/// Parent Class (Superclass)
class MenuItem {
  final String id;
  final String nama;
  final int hargaDasar;
  final String kategori;
  final int estimasiMenit;

  MenuItem({
    required this.id,
    required this.nama,
    required this.hargaDasar,
    required this.kategori,
    required this.estimasiMenit,
  });

  /// Method yang dapat di-override oleh subclass
  int hitungHargaAkhir() => hargaDasar;

  String tampilkanInfo() {
    return '[$id] $nama ($kategori) - ${formatRupiah(hitungHargaAkhir())} '
        '| Est. $estimasiMenit menit';
  }
}

/// Subclass 1: MakananBerat mewarisi MenuItem
class MakananBerat extends MenuItem {
  final int levelPedas;
  final bool termasukNasi;

  MakananBerat({
    required super.id,
    required super.nama,
    required super.hargaDasar,
    required super.estimasiMenit,
    required this.levelPedas,
    this.termasukNasi = true,
  }) : super(kategori: 'Makanan Berat');

  @override
  String tampilkanInfo() {
    final infoNasi = termasukNasi ? 'Sudah termasuk nasi' : 'Tanpa nasi';
    return '${super.tampilkanInfo()} | Pedas Lv.$levelPedas ($infoNasi)';
  }
}

/// Subclass 2: Minuman mewarisi MenuItem
class Minuman extends MenuItem {
  final String ukuran; // 'M' atau 'L'
  final bool dingin;

  Minuman({
    required super.id,
    required super.nama,
    required super.hargaDasar,
    required super.estimasiMenit,
    this.ukuran = 'M',
    this.dingin = true,
  }) : super(kategori: 'Minuman');

  /// Override: ukuran 'L' menambah biaya Rp2.000
  @override
  int hitungHargaAkhir() {
    return ukuran.toUpperCase() == 'L' ? hargaDasar + 2000 : hargaDasar;
  }

  @override
  String tampilkanInfo() {
    final penyajian = dingin ? 'Dingin/Es' : 'Panas/Hangat';
    return '${super.tampilkanInfo()} | Ukuran $ukuran ($penyajian)';
  }
}

/// Subclass 3: MenuPaket mewarisi MenuItem dengan potongan diskon
class MenuPaket extends MenuItem {
  final List<String> daftarIsi;
  final int diskonPersen;

  MenuPaket({
    required super.id,
    required super.nama,
    required super.hargaDasar,
    required super.estimasiMenit,
    required this.daftarIsi,
    required this.diskonPersen,
  }) : super(kategori: 'Paket Hemat');

  /// Override: menghitung harga setelah diskon paket
  @override
  int hitungHargaAkhir() {
    final potongan = (hargaDasar * diskonPersen) ~/ 100;
    return hargaDasar - potongan;
  }

  @override
  String tampilkanInfo() {
    return '${super.tampilkanInfo()} | Isi: ${daftarIsi.join(" + ")} '
        '(Hemat $diskonPersen%)';
  }
}

void main() {
  print('=== DEMO TUGAS 2A: OOP & INHERITANCE CERDASCANTEEN ===\n');

  // Polymorphism: menyimpan berbagai subclass dalam List<MenuItem>
  final List<MenuItem> pesananMahasiswa = [
    MakananBerat(
      id: 'MK01',
      nama: 'Nasi Ayam Geprek',
      hargaDasar: 15000,
      estimasiMenit: 7,
      levelPedas: 3,
      termasukNasi: true,
    ),
    Minuman(
      id: 'MN01',
      nama: 'Es Teh Tarik',
      hargaDasar: 6000,
      estimasiMenit: 2,
      ukuran: 'L',
      dingin: true,
    ),
    MenuPaket(
      id: 'PK01',
      nama: 'Paket Hemat Istirahat',
      hargaDasar: 22000,
      estimasiMenit: 8,
      daftarIsi: ['Nasi Goreng Spesial', 'Es Jeruk'],
      diskonPersen: 15,
    ),
  ];

  int totalBayar = 0;
  int totalEstimasi = 0;

  for (final item in pesananMahasiswa) {
    print(item.tampilkanInfo());
    totalBayar += item.hitungHargaAkhir();
    totalEstimasi += item.estimasiMenit;
  }

  print('\n------------------------------------------------------');
  print('Jumlah Item     : ${pesananMahasiswa.length} menu');
  print('Total Pembayaran: ${formatRupiah(totalBayar)}');
  print('Estimasi Selesai: ~$totalEstimasi menit');
}
