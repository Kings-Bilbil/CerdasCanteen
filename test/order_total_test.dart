import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/order.dart';
import 'package:tubes_perak/models/order_item.dart';

void main() {
  group('OrderItem.subtotal', () {
    test('harga x qty', () {
      const OrderItem item = OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2);
      expect(item.subtotal, 30000);
    });

    test('qty 1 sama dengan harga satuan', () {
      const OrderItem item = OrderItem(name: 'Es Teh', price: 5000, qty: 1);
      expect(item.subtotal, 5000);
    });
  });

  group('Order.totalPrice (total harga keranjang)', () {
    test('menjumlahkan subtotal semua item', () {
      const Order order = Order(
        id: 'CC-1',
        items: <OrderItem>[
          OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2), // 30000
          OrderItem(name: 'Es Teh', price: 5000, qty: 3), // 15000
        ],
      );
      expect(order.totalPrice, 45000);
      expect(order.totalItems, 5);
    });

    test('keranjang kosong bernilai 0 dan ditandai kosong', () {
      const Order order = Order(id: 'CC-2', items: <OrderItem>[]);
      expect(order.totalPrice, 0);
      expect(order.totalItems, 0);
      expect(order.isEmpty, isTrue);
    });

    test('satu item tetap dihitung benar', () {
      const Order order = Order(
        id: 'CC-3',
        items: <OrderItem>[OrderItem(name: 'Mie Ayam', price: 12000, qty: 1)],
      );
      expect(order.totalPrice, 12000);
    });
  });
}
