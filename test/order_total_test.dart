import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/order.dart';
import 'package:tubes_perak/models/order_item.dart';

// ============================================================================
// FILE TEST: total harga keranjang
//
// Cara membaca kegagalan:
//   - "Expected: <45000> Actual: <...>" -> rumus subtotal/total berubah.
//   - "Actual: <0>" padahal item ada    -> items tidak terbaca / qty 0.
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
            'Bila gagal: getter subtotal bukan price * qty, atau salah '
            'satu field tertukar (mis. price*qty dibalik).',
      );
    });

    test('qty 1 sama dengan harga satuan', () {
      const OrderItem item = OrderItem(name: 'Es Teh', price: 5000, qty: 1);
      expect(
        item.subtotal,
        5000,
        reason: 'INPUT qty=1 -> subtotal harus sama dengan harga satuan. '
            'Bila gagal: ada tambahan biaya/diskonto tersembunyi di subtotal.',
      );
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
      expect(
        order.totalPrice,
        45000,
        reason: 'INPUT 2 item (30000 + 15000) -> HARAP 45000. '
            'Bila dapat 35000: qty salah satu item diabaikan. '
            'Bila dapat 20000: hanya harga satuan yang dijumlah.',
      );
      expect(
        order.totalItems,
        5,
        reason: 'totalItems menghitung KUANTITAS (2+3=5), bukan jumlah baris '
            '(2). Bila dapat 2: yang dipakai items.length.',
      );
    });

    test('keranjang kosong bernilai 0 dan ditandai kosong', () {
      const Order order = Order(id: 'CC-2', items: <OrderItem>[]);
      expect(
        order.totalPrice,
        0,
        reason: 'Keranjang kosong tidak boleh menghasilkan null/error. '
            'Bila gagal: fold tanpa initialValue atau ada biaya minimum.',
      );
      expect(
        order.totalItems,
        0,
        reason: 'Tidak ada item berarti total kuantitas 0.',
      );
      expect(
        order.isEmpty,
        isTrue,
        reason: 'isEmpty dipakai UI untuk menolak checkout. '
            'Bila false pada keranjang kosong: validasi checkout tidak jalan.',
      );
    });

    test('satu item tetap dihitung benar', () {
      const Order order = Order(
        id: 'CC-3',
        items: <OrderItem>[OrderItem(name: 'Mie Ayam', price: 12000, qty: 1)],
      );
      expect(
        order.totalPrice,
        12000,
        reason: 'INPUT 1 item qty 1 -> HARAP 12000. Kasus batas: pastikan '
            'tidak ada pembulatan atau minimum order yang menambah nilai.',
      );
    });
  });
}
