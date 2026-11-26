import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tubes_perak/models/order.dart';
import 'package:tubes_perak/models/order_item.dart';
import 'package:tubes_perak/screens/qr_receipt_screen.dart';

const Order _order = Order(
  id: 'CC-2024',
  items: <OrderItem>[
    OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2),
    OrderItem(name: 'Es Teh', price: 5000, qty: 1),
  ],
  status: OrderStatus.diproses,
  queueLength: 3, // 3 antrean x 3 + 3 item x 2 = 15 menit
);

void main() {
  group('QrReceiptScreen', () {
    testWidgets('menampilkan widget QR, estimasi, dan total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: QrReceiptScreen(order: _order)),
      );
      await tester.pumpAndSettle();

      // Widget QR harus dirender.
      expect(find.byType(QrImageView), findsOneWidget);

      // Estimasi dari queue_estimator: (3*3) + (3*2) = 15 menit.
      expect(find.text('15 menit'), findsOneWidget);

      // Data struk.
      expect(find.textContaining('CC-2024'), findsWidgets);
      expect(find.text('Rp35.000'), findsOneWidget);
      expect(find.text('Rp30.000'), findsOneWidget); // subtotal nasi goreng
      expect(find.text('Rp5.000'), findsWidgets); // es teh
      expect(find.text('Nasi Goreng'), findsOneWidget);
      expect(find.text('Es Teh'), findsOneWidget);
      expect(find.text('Diproses'), findsOneWidget);
      expect(find.text('3 orang'), findsOneWidget);
      expect(
        find.text('Tunjukkan QR ini ke kasir saat mengambil pesanan.'),
        findsOneWidget,
      );
    });

    testWidgets('estimasi manual mengalahkan hasil hitung otomatis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QrReceiptScreen(order: _order, estimateMinutes: 25),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('25 menit'), findsOneWidget);
      expect(find.text('15 menit'), findsNothing);
    });

    testWidgets('data QR memuat ringkasan pesanan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: QrReceiptScreen(order: _order)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);

      const QrReceiptScreen screen = QrReceiptScreen(order: _order);
      expect(screen.qrData, contains('CERDASCANTEEN'));
      expect(screen.qrData, contains('ID:CC-2024'));
      expect(screen.qrData, contains('TOTAL:35000'));
      expect(screen.qrData, contains('EST:15'));
      expect(screen.resolvedEstimate, 15);
    });

    testWidgets('status Siap Diambil tampil sebagai chip', (
      WidgetTester tester,
    ) async {
      const Order ready = Order(
        id: 'CC-77',
        items: <OrderItem>[
          OrderItem(name: 'Mie Ayam', price: 12000, qty: 1),
        ],
        status: OrderStatus.siapDiambil,
      );

      await tester.pumpWidget(
        const MaterialApp(home: QrReceiptScreen(order: ready)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Siap Diambil'), findsOneWidget);
      // queueLength 0, itemCount 1 -> 2 menit.
      expect(find.text('2 menit'), findsOneWidget);
    });
  });
}
