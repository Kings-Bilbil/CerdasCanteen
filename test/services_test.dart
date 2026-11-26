import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/services/device_service.dart';
import 'package:tubes_perak/services/notification_service.dart';
import 'package:tubes_perak/models/order.dart';
import 'package:tubes_perak/utils/formatters.dart';

void main() {
  group('buildOrderStatusContent - Diproses', () {
    test('judul memuat ID pesanan', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.diproses,
        orderId: 'CC-9',
      );
      expect(c.title, contains('Diproses'));
      expect(c.title, contains('CC-9'));
      expect(c.body, contains('sedang dibuat'));
    });
  });

  group('buildOrderStatusContent - Siap Diambil', () {
    test('menyertakan estimasi bila diberikan', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.siapDiambil,
        orderId: 'CC-1',
        estimateMinutes: 9,
      );
      expect(c.title, contains('Siap Diambil'));
      expect(c.body, contains('±9 menit'));
    });

    test('tetap valid tanpa estimasi', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.siapDiambil,
      );
      expect(c.title, contains('Siap Diambil'));
      expect(c.body, isNot(contains('menit')));
      expect(c.title, isNot(contains('#')));
    });
  });

  group('buildOrderStatusContent - Selesai', () {
    test('judul & isi sesuai', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.selesai,
        orderId: 'CC-3',
      );
      expect(c.title, 'Pesanan #CC-3 Selesai');
      expect(c.body, contains('Terima kasih'));
    });
  });

  group('DeviceSummary.fromRaw', () {
    test('menyusun entri Android lengkap', () {
      final DeviceSummary s = DeviceSummary.fromRaw(
        manufacturer: 'samsung',
        model: 'SM-A525F',
        brand: 'samsung',
        device: 'a52q',
        androidVersion: '13',
        sdkInt: 33,
        now: DateTime(2026, 1, 5, 9, 7),
      );
      final Map<String, String> map = <String, String>{
        for (final DeviceInfoEntry e in s.displayed) e.label: e.value,
      };
      expect(map['Perangkat'], 'samsung SM-A525F');
      expect(map['Versi Android'], 'Android 13 (API 33)');
      expect(map['Login terakhir'], '05/01/2026 09:07');
    });

    test('data kosong tidak menghasilkan entri kosong', () {
      final DeviceSummary s = DeviceSummary.fromRaw(
        manufacturer: '  ',
        model: '',
        now: DateTime(2026, 2, 1),
      );
      expect(s.displayed.any((DeviceInfoEntry e) => e.label == 'Perangkat'),
          isFalse);
      expect(s.displayed.every((DeviceInfoEntry e) => e.value.trim().isNotEmpty),
          isTrue);
    });

    test('token panjang dipotong', () {
      final DeviceSummary s = DeviceSummary.fromRaw(
        fcmToken: 'abcdefghijklmnopqrstuvwxyz',
        now: DateTime(2026, 1, 1),
      );
      final String token = s.displayed
          .firstWhere((DeviceInfoEntry e) => e.label == 'Token notifikasi')
          .value;
      expect(token.contains('…'), isTrue);
      expect(token.length < 27, isTrue);
    });
  });

  group('Formatters', () {
    test('formatRupiah memberi pemisah ribuan', () {
      expect(formatRupiah(15000), 'Rp15.000');
      expect(formatRupiah(500), 'Rp500');
      expect(formatRupiah(1234567), 'Rp1.234.567');
      expect(formatRupiah(0), 'Rp0');
    });

    test('formatEstimasiMenit di bawah satu jam', () {
      expect(formatEstimasiMenit(13), '13 menit');
    });

    test('formatEstimasiMenit satu jam lebih', () {
      expect(formatEstimasiMenit(65), '1 jam 5 menit');
      expect(formatEstimasiMenit(120), '2 jam');
    });
  });
}
