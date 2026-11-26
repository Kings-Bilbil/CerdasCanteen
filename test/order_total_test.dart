import 'package:flutter_test/flutter_test.dart';
import 'fixtures/models/order.dart';
import 'fixtures/models/order_item.dart';

// ============================================================================
// UNIT TEST 1 — total harga keranjang
//
// Cara membaca kegagalan:
//   "Expected: <45000> Actual: <...>"  -> rumus subtotal/total berubah.
//
// Setiap expect memakai `reason:` berisi INPUT -> HARAPAN -> PENYEBAB UMUM.
// ============================================================================

void main() {
  group('OrderItem.subtotal', () {
    test('harga x qty', () {
      const OrderItem item =
          OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2);
      expect(
        item.subtotal,
        30000,
        reason: 'INPUT harga=15000, qty=2 -> HARAP 30000. '
            'Bila gagal: getter subtotal bukan price * qty.',
      );
    });
  });

  group('Order.totalPrice', () {
    test('menjumlahkan subtotal semua item', () {
      const Order order = Order(
        id: 'CC-1',
        items: <OrderItem>[
          OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2), // 30000
          OrderItem(name: 'Es Teh', price: 5000, qty: 3), // 15000
        ],
      );
      expect(
        order.totalPrice,
        45000,
        reason: 'INPUT 2 item (30000 + 15000) -> HARAP 45000. '
            'Bila 35000: qty salah satu item diabaikan.',
      );
      expect(
        order.totalItems,
        5,
        reason: 'totalItems menghitung KUANTITAS (2+3=5), bukan jumlah baris. '
            'Bila 2: yang dipakai items.length.',
      );
    });

    test('keranjang kosong bernilai 0 dan ditandai kosong', () {
      const Order order = Order(id: 'CC-2', items: <OrderItem>[]);
      expect(
        order.totalPrice,
        0,
        reason: 'Keranjang kosong tidak boleh error. '
            'Bila gagal: fold tanpa initialValue.',
      );
      expect(
        order.isEmpty,
        isTrue,
        reason: 'isEmpty dipakai UI untuk menolak checkout. '
            'Bila false: validasi checkout tidak jalan.',
      );
    });
  });
}
