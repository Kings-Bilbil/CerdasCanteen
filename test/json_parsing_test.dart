import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/order.dart';
import 'package:tubes_perak/models/order_item.dart';

void main() {
  group('OrderItem.fromJson', () {
    test('parsing JSON normal', () {
      final OrderItem item = OrderItem.fromJson(<String, dynamic>{
        'nama': 'Nasi Goreng',
        'harga': 15000,
        'qty': 2,
      });
      expect(item.name, 'Nasi Goreng');
      expect(item.price, 15000);
      expect(item.qty, 2);
      expect(item.subtotal, 30000);
    });

    test('parsing dari string JSON (angka dikirim sebagai teks)', () {
      final Map<String, dynamic> json =
          jsonDecode('{"nama":"Es Jeruk","harga":"8000","qty":"2"}')
              as Map<String, dynamic>;
      final OrderItem item = OrderItem.fromJson(json);
      expect(item.price, 8000);
      expect(item.qty, 2);
    });

    test('mendukung alias field bahasa Inggris', () {
      final OrderItem item = OrderItem.fromJson(<String, dynamic>{
        'name': 'Bakso',
        'price': 13000,
      });
      expect(item.name, 'Bakso');
      expect(item.price, 13000);
      expect(item.qty, 1, reason: 'qty default 1 bila tidak dikirim');
    });

    test('nama kosong melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(<String, dynamic>{'harga': 1000, 'qty': 1}),
        throwsFormatException,
      );
    });

    test('harga negatif melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': -1, 'qty': 1}),
        throwsFormatException,
      );
    });

    test('qty 0 melempar FormatException', () {
      expect(
        () => OrderItem.fromJson(
            <String, dynamic>{'nama': 'X', 'harga': 1000, 'qty': 0}),
        throwsFormatException,
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
      expect(order.id, 'CC-100');
      expect(order.status, OrderStatus.siapDiambil);
      expect(order.queueLength, 4);
      expect(order.items.length, 2);
      expect(order.totalPrice, 35000);
      expect(order.totalItems, 3);
    });

    test('status tidak dikenal jatuh ke Diproses', () {
      final Order order = Order.fromJson(<String, dynamic>{
        'id': 'CC-101',
        'status': 'entah apa',
        'items': <dynamic>[
          <String, dynamic>{'nama': 'Teh', 'harga': 3000, 'qty': 1},
        ],
      });
      expect(order.status, OrderStatus.diproses);
    });

    test('items bukan array melempar FormatException', () {
      expect(
        () => Order.fromJson(<String, dynamic>{'id': 'x', 'items': 'salah'}),
        throwsFormatException,
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
      expect(hasil.id, awal.id);
      expect(hasil.totalPrice, awal.totalPrice);
      expect(hasil.status, awal.status);
      expect(hasil.queueLength, awal.queueLength);
    });
  });
}
