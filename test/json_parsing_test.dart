import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'fixtures/models/order.dart';
import 'fixtures/models/order_item.dart';

// ============================================================================
// FILE TEST: parsing JSON pesanan
//
// Cara membaca kegagalan:
//   - "Expected: FormatException Actual: ..." -> validasi data tidak ada.
//   - "type 'String' is not a subtype of 'int'" -> field angka diubah jadi double.
//   - "Instance of 'OrderItem'" di teks -> interpolasi objek, bukan field.
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
            'Bila kosong: kunci "nama" tidak terbaca (mungkin alias salah).',
      );
      expect(
        item.price,
        15000,
        reason: 'INPUT harga=15000 -> HARAP price 15000 sebagai int. '
            'Bila 15000.0: field price berubah menjadi double.',
      );
      expect(
        item.qty,
        2,
        reason: 'INPUT qty=2 -> HARAP 2. Bila 1: default qty menimpa nilai '
            'yang dikirim (urutan alias terbalik).',
      );
      expect(
        item.subtotal,
        30000,
        reason: 'subtotal = harga x qty = 30000. Bila gagal: parsing '
            'berhasil tapi salah satu nilai berubah saat dikonversi.',
      );
    });

    test('parsing dari string JSON (angka dikirim sebagai teks)', () {
      final Map<String, dynamic> json =
          jsonDecode('{"nama":"Es Jeruk","harga":"8000","qty":"2"}')
              as Map<String, dynamic>;
      final OrderItem item = OrderItem.fromJson(json);
      expect(
        item.price,
        8000,
        reason: 'INPUT harga="8000" (string) -> HARAP 8000 (int). '
            'Bila FormatException: int.tryParse belum dipakai untuk string.',
      );
      expect(
        item.qty,
        2,
        reason: 'INPUT qty="2" (string) -> HARAP 2 (int).',
      );
    });

    test('mendukung alias field bahasa Inggris', () {
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
        item.price,
        13000,
        reason: 'INPUT price (bukan harga) -> HARAP terbaca. '
            'Bila FormatException: alias "price" belum ada.',
      );
      expect(
        item.qty,
        1,
        reason: 'INPUT tanpa qty -> HARAP default 1. Bila 0: default salah '
            'dan item akan dianggap tidak valid.',
      );
    });

    test('nama kosong melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(<String, dynamic>{'harga': 1000, 'qty': 1}),
        throwsFormatException,
        reason: 'INPUT tanpa nama -> HARAP FormatException. '
            'Bila gagal: item tanpa nama lolos dan tampil kosong di struk.',
      );
    });

    test('harga negatif melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': -1, 'qty': 1}),
        throwsFormatException,
        reason: 'INPUT harga=-1 -> HARAP FormatException. '
            'Bila gagal: total keranjang bisa berkurang karena item negatif.',
      );
    });

    test('qty 0 melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': 1000, 'qty': 0}),
        throwsFormatException,
        reason: 'INPUT qty=0 -> HARAP FormatException. '
            'Bila gagal: item tak terlihat (subtotal 0) tetap masuk keranjang.',
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
        reason: 'INPUT id="CC-100" -> HARAP sama. Bila kosong: kunci id '
            'tidak terbaca atau di-override nilai default.',
      );
      expect(
        order.status,
        OrderStatus.siapDiambil,
        reason: 'INPUT status="Siap Diambil" -> HARAP siapDiambil. '
            'Bila diproses: pencocokan label (dengan spasi & kapital) gagal.',
      );
      expect(
        order.queueLength,
        4,
        reason: 'INPUT queue_length=4 -> HARAP 4. Bila 0: kunci snake_case '
            'tidak dibaca (mungkin hanya queueLength camelCase).',
      );
      expect(
        order.items.length,
        2,
        reason: 'INPUT 2 item -> HARAP 2 baris.',
      );
      expect(
        order.totalPrice,
        35000,
        reason: '2x15000 + 1x5000 = 35000. Bila beda: parsing qty salah.',
      );
      expect(
        order.totalItems,
        3,
        reason: 'totalItems = 2+1 = 3 (kuantitas, bukan baris).',
      );
    });

    test('status tidak dikenal jatuh ke Diproses', () {
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
            'Bila melempar error: fromString tidak memakai orElse.',
      );
    });

    test('items bukan array melempar FormatException', () {
      expect(
        () => Order.fromJson(<String, dynamic>{'id': 'x', 'items': 'salah'}),
        throwsFormatException,
        reason: 'INPUT items="salah" (string) -> HARAP FormatException. '
            'Bila gagal: iterasi string menghasilkan item per karakter.',
      );
    });

    test('round-trip toJson -> fromJson konsisten', () {
      const Order awal = Order(
        id: 'CC-7',
        items: <OrderItem>[
          OrderItem(name: 'Sate', price: 20000, qty: 2),
        ],
        status: OrderStatus.siapDiambil,
        queueLength: 2,
      );
      final Order hasil = Order.fromJson(
        jsonDecode(jsonEncode(awal.toJson())) as Map<String, dynamic>,
      );
      expect(
        hasil.id,
        awal.id,
        reason: 'toJson lalu fromJson harus mengembalikan id yang sama. '
            'Bila beda: kunci id tidak konsisten antar kedua method.',
      );
      expect(
        hasil.totalPrice,
        awal.totalPrice,
        reason: 'Nilai total harus bertahan melewati serialisasi. '
            'Bila 0: items hilang saat toJson/fromJson.',
      );
      expect(
        hasil.status,
        awal.status,
        reason: 'Status harus bertahan. Bila berubah ke diproses: label '
            'yang ditulis toJson tidak dikenali fromString.',
      );
      expect(
        hasil.queueLength,
        awal.queueLength,
        reason: 'queueLength harus bertahan. Bila 0: kunci queue_length '
            'tidak ditulis atau tidak dibaca.',
      );
    });
  });
}
