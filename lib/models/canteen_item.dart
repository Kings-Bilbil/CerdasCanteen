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

class CanteenMenu {
  final String id;
  final String nama;
  final int harga;
  final String kategori;
  final String deskripsi;
  final String gambarUrl;
  final int estimasiMenit;
  final bool tersedia;

  const CanteenMenu({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.deskripsi,
    required this.gambarUrl,
    this.estimasiMenit = 5,
    this.tersedia = true,
  });
}

class CartItem {
  final CanteenMenu menu;
  int qty;
  final String catatan;
  final bool takeAway;
  final bool ekstraPedas;

  CartItem({
    required this.menu,
    this.qty = 1,
    this.catatan = '',
    this.takeAway = false,
    this.ekstraPedas = false,
  });

  /// Tambahan biaya kemasan Rp1.000 jika Take-Away (Bungkus)
  int get biayaKemasan => takeAway ? 1000 : 0;

  int get hargaSatuanFinal => menu.harga + biayaKemasan;

  int get subtotal => hargaSatuanFinal * qty;
}

class OrderRecord {
  final String kodePesanan;
  final String namaPemesan;
  final String metodeBayar;
  final int totalItem;
  final int totalHarga;
  final String status;
  final DateTime waktuPesan;

  const OrderRecord({
    required this.kodePesanan,
    required this.namaPemesan,
    required this.metodeBayar,
    required this.totalItem,
    required this.totalHarga,
    required this.status,
    required this.waktuPesan,
  });
}
