/// Model item pesanan pada CerdasCanteen.
///
/// Dibuat oleh Anggota 3 sebagai fondasi karena model keranjang dari
/// Anggota 1 belum tersedia. Nama field JSON sengaja mengikuti gaya API
/// kantin (`nama`, `harga`, `qty`) agar mudah dipakai lintas anggota.
class OrderItem {
  final String name;
  final int price; // harga satuan dalam rupiah
  final int qty;

  const OrderItem({
    required this.name,
    required this.price,
    required this.qty,
  });

  /// Subtotal item = harga satuan x jumlah.
  int get subtotal => price * qty;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final Object? rawName = json['nama'] ?? json['name'];
    if (rawName is! String || rawName.trim().isEmpty) {
      throw const FormatException('Field "nama" wajib ada dan berupa teks');
    }

    // JSON dari API kadang mengirim angka sebagai String ("15000").
    final int price = _parseInt(json['harga'] ?? json['price'], 'harga');
    final int qty = _parseInt(json['qty'] ?? json['jumlah'], 'qty', fallback: 1);

    if (price < 0) {
      throw const FormatException('Harga tidak boleh negatif');
    }
    if (qty <= 0) {
      throw const FormatException('Jumlah item harus minimal 1');
    }

    return OrderItem(name: rawName.trim(), price: price, qty: qty);
  }

  Map<String, dynamic> toJson() => {
        'nama': name,
        'harga': price,
        'qty': qty,
      };

  static int _parseInt(Object? value, String field, {int? fallback}) {
    if (value == null) {
      if (fallback != null) return fallback;
      throw FormatException('Field "$field" tidak ditemukan');
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final int? parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    throw FormatException('Field "$field" tidak valid: $value');
  }
}
