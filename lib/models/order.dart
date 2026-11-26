import 'order_item.dart';

/// Status pesanan pada alur CerdasCanteen.
enum OrderStatus {
  diproses('Diproses'),
  siapDiambil('Siap Diambil'),
  selesai('Selesai');

  const OrderStatus(this.label);

  /// Teks yang ditampilkan ke pengguna dan dipakai pada notifikasi.
  final String label;

  static OrderStatus fromString(String value) {
    final String v = value.toLowerCase().trim();
    return OrderStatus.values.firstWhere(
      (OrderStatus s) =>
          s.label.toLowerCase() == v || s.name.toLowerCase() == v,
      orElse: () => OrderStatus.diproses,
    );
  }
}

/// Pesanan mahasiswa di kantin.
class Order {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;

  /// Jumlah orang yang mengantre di depan pesanan ini.
  final int queueLength;

  const Order({
    required this.id,
    required this.items,
    this.status = OrderStatus.diproses,
    this.queueLength = 0,
  });

  /// Total harga keranjang (belum termasuk diskon/pajak).
  int get totalPrice =>
      items.fold(0, (int sum, OrderItem item) => sum + item.subtotal);

  /// Total kuantitas item (bukan jumlah baris).
  int get totalItems =>
      items.fold(0, (int sum, OrderItem item) => sum + item.qty);

  bool get isEmpty => items.isEmpty;

  factory Order.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Field "items" harus berupa array');
    }

    final List<OrderItem> items = rawItems
        .map((Object? e) {
          if (e is! Map) {
            throw const FormatException('Setiap item harus berupa objek');
          }
          return OrderItem.fromJson(Map<String, dynamic>.from(e));
        })
        .toList();

    final int queueLength =
        json['queue_length'] is int ? json['queue_length'] as int : 0;

    return Order(
      id: (json['id'] ?? '').toString(),
      items: items,
      status: OrderStatus.fromString((json['status'] ?? '').toString()),
      queueLength: queueLength,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((OrderItem e) => e.toJson()).toList(),
        'status': status.label,
        'queue_length': queueLength,
      };
}
