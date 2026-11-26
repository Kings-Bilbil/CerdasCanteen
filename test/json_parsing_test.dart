import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'fixtures/models/order.dart';
import 'fixtures/models/order_item.dart';

// ============================================================================
// UNIT TEST 2 — parsing JSON pesanan
//
// Cara membaca kegagalan:
//   "Expected: FormatException"  -> validasi data tidak ada.
//   "type 'String' is not a subtype of 'int'" -> konversi angka belum ada.
//
// Setiap expect memakai `reason:` berisi INPUT -> HARAPAN -> PENYEBAB UMUM.
// ============================================================================

void main() {
  group('OrderItem.fromJson', () {
    test('parsing JSON normal', () {
      final OrderItem item = OrderItem.fromJson(<String, dynamic>{
        'nama': 'Nasi Goreng',
        'harga': 15000,
        'qty': 2,
      });
      expect(
        item.name,
        'Nasi Goreng',
        reason: 'INPUT nama="Nasi Goreng" -> HARAP name sama. '
            'Bila kosong: kunci "nama" tidak terbaca (alias salah).',
      );
      expect(
        item.subtotal,
        30000,
        reason: 'subtotal = 15000 x 2 = 30000. '
            'Bila beda: nilai berubah saat dikonversi.',
      );
    });

    test('angka dikirim sebagai teks tetap terbaca', () {
      final Map<String, dynamic> json =
          jsonDecode('{"nama":"Es Jeruk","harga":"8000","qty":"2"}')
              as Map<String, dynamic>;
      final OrderItem item = OrderItem.fromJson(json);
      expect(
        item.price,
        8000,
        reason: 'INPUT harga="8000" (string) -> HARAP 8000 (int). '
            'Bila FormatException: int.tryParse belum dipakai.',
      );
      expect(
        item.qty,
        2,
        reason: 'INPUT qty="2" (string) -> HARAP 2 (int).',
      );
    });

    test('alias bahasa Inggris dan qty default', () {
      final OrderItem item = OrderItem.fromJson(<String, dynamic>{
        'name': 'Bakso',
        'price': 13000,
      });
      expect(
        item.name,
        'Bakso',
        reason: 'INPUT name (bukan nama) -> HARAP terbaca. '
            'Bila kosong: alias "name" belum ditambahkan.',
      );
      expect(
        item.qty,
        1,
        reason: 'INPUT tanpa qty -> HARAP default 1. '
            'Bila 0: item dianggap tidak valid.',
      );
    });

    test('data tidak valid ditolak', () {
      expect(
        () => OrderItem.fromJson(<String, dynamic>{'harga': 1000, 'qty': 1}),
        throwsFormatException,
        reason: 'INPUT tanpa nama -> HARAP FormatException. '
            'Bila lolos: item tanpa nama tampil kosong di struk.',
      );
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': -1, 'qty': 1}),
        throwsFormatException,
        reason: 'INPUT harga=-1 -> HARAP FormatException. '
            'Bila lolos: total keranjang bisa berkurang.',
      );
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': 1000, 'qty': 0}),
        throwsFormatException,
        reason: 'INPUT qty=0 -> HARAP FormatException. '
            'Bila lolos: item tak terlihat tetap masuk keranjang.',
      );
    });
  });

  group('Order.fromJson', () {
    test('parsing order lengkap', () {
      final Map<String, dynamic> json = jsonDecode('''
      {
        "id": "CC-100",
        "status": "Siap Diambil",
        "queue_length": 4,
        "items": [
          {"nama": "Nasi Goreng", "harga": 15000, "qty": 2},
          {"nama": "Es Teh", "harga": 5000, "qty": 1}
        ]
      }
      ''') as Map<String, dynamic>;

      final Order order = Order.fromJson(json);
      expect(
        order.id,
        'CC-100',
        reason: 'INPUT id="CC-100" -> HARAP sama. '
            'Bila kosong: kunci id tidak terbaca.',
      );
      expect(
        order.status,
        OrderStatus.siapDiambil,
        reason: 'INPUT status="Siap Diambil" -> HARAP siapDiambil. '
            'Bila diproses: pencocokan label (spasi & kapital) gagal.',
      );
      expect(
        order.queueLength,
        4,
        reason: 'INPUT queue_length=4 -> HARAP 4. '
            'Bila 0: kunci snake_case tidak dibaca.',
      );
      expect(
        order.totalPrice,
        35000,
        reason: '2x15000 + 1x5000 = 35000. Bila beda: parsing qty salah.',
      );
    });

    test('status tak dikenal dan items salah ditangani', () {
      final Order order = Order.fromJson(<String, dynamic>{
        'id': 'CC-101',
        'status': 'entah apa',
        'items': <dynamic>[
          <String, dynamic>{'nama': 'Teh', 'harga': 3000, 'qty': 1},
        ],
      });
      expect(
        order.status,
        OrderStatus.diproses,
        reason: 'INPUT status tak dikenal -> HARAP diproses (status aman). '
            'Bila error: fromString tidak memakai orElse.',
      );
      expect(
        () => Order.fromJson(<String, dynamic>{'id': 'x', 'items': 'salah'}),
        throwsFormatException,
        reason: 'INPUT items="salah" (string) -> HARAP FormatException. '
            'Bila lolos: iterasi string menghasilkan item per karakter.',
      );
    });
  });
}
