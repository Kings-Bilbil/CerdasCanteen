import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/screens/profile_screen.dart';
import 'package:tubes_perak/services/device_service.dart';

/// Loader palsu: menggantikan plugin native di lingkungan test.
DeviceService _fakeService({int delayMs = 0}) {
  return DeviceService(
    loader: () async {
      if (delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
      return DeviceSummary.fromRaw(
        manufacturer: 'Google',
        model: 'Pixel 6',
        androidVersion: '14',
        sdkInt: 34,
        now: DateTime(2026, 3, 2, 10, 30),
      );
    },
  );
}

void main() {
  group('ProfileScreen', () {
    testWidgets('menampilkan identitas mahasiswa dan info perangkat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            studentName: 'Budi Santoso',
            studentId: '2210512999',
            deviceService: _fakeService(),
          ),
        ),
      );

      // FutureBuilder masih menunggu pada frame pertama.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('NIM 2210512999'), findsOneWidget);
      expect(find.text('Informasi Perangkat'), findsOneWidget);
      expect(find.text('Google Pixel 6'), findsOneWidget);
      expect(find.text('Android 14 (API 34)'), findsOneWidget);
      expect(find.text('Notifikasi Pesanan'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Coba Notifikasi "Siap Diambil"'),
        findsOneWidget,
      );
    });

    testWidgets('tombol refresh memuat ulang info perangkat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(deviceService: _fakeService())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Google Pixel 6'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('loader gagal tetap menampilkan fallback, bukan error', (
      WidgetTester tester,
    ) async {
      final DeviceService failing = DeviceService(
        loader: () async => throw Exception('plugin tidak tersedia'),
      );

      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(deviceService: failing)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak diketahui'), findsOneWidget);
      expect(find.textContaining('Gagal membaca'), findsNothing);
    });
  });
}
