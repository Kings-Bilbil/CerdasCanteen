import 'package:flutter_test/flutter_test.dart';
import 'fixtures/models/order.dart';
import 'fixtures/services/device_service.dart';
import 'fixtures/services/notification_service.dart';
import 'fixtures/utils/formatters.dart';

// ============================================================================
// FILE TEST: bagian murni dari service + formatter
//
// Yang diuji di sini adalah fungsi TANPA plugin native, sehingga bisa jalan
// di FlutLab. Kalau file ini merah, penyebabnya hampir selalu teks/label yang
// berubah, bukan masalah platform.
//
// Cara membaca kegagalan:
//   - "Expected: contains 'Siap Diambil'" -> label status diubah.
//   - "Expected: 'Rp15.000' Actual: 'Rp 15.000'" -> format menambah spasi.
// ============================================================================

void main() {
  group('buildOrderStatusContent - Diproses', () {
    test('judul memuat ID pesanan', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.diproses,
        orderId: 'CC-9',
      );
      expect(
        c.title,
        contains('Diproses'),
        reason: 'INPUT status diproses -> HARAP judul memuat "Diproses". '
            'Bila tidak: cabang switch untuk diproses tertukar.',
      );
      expect(
        c.title,
        contains('CC-9'),
        reason: 'INPUT orderId="CC-9" -> HARAP muncul di judul. '
            'Bila tidak: variabel suffix tidak dipakai pada cabang ini.',
      );
      expect(
        c.body,
        contains('sedang dibuat'),
        reason: 'Isi notifikasi harus menjelaskan bahwa pesanan sedang '
            'dibuat, supaya pengguna tahu harus menunggu.',
      );
    });
  });

  group('buildOrderStatusContent - Siap Diambil', () {
    test('menyertakan estimasi bila diberikan', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.siapDiambil,
        orderId: 'CC-1',
        estimateMinutes: 9,
      );
      expect(
        c.title,
        contains('Siap Diambil'),
        reason: 'INPUT status siapDiambil -> HARAP judul "Siap Diambil". '
            'Bila "siapDiambil": UI memakai status.name, bukan label.',
      );
      expect(
        c.body,
        contains('±9 menit'),
        reason: 'INPUT estimateMinutes=9 -> HARAP "±9 menit". '
            'Bila tanpa "±": format estimasi berubah. Bila tanpa angka: '
            'estimateMinutes tidak diteruskan ke buildOrderStatusContent.',
      );
    });

    test('tetap valid tanpa estimasi', () {
      final NotificationContent c =
          buildOrderStatusContent(OrderStatus.siapDiambil);
      expect(
        c.title,
        contains('Siap Diambil'),
        reason: 'Tanpa orderId & estimasi, judul tetap harus benar.',
      );
      expect(
        c.body,
        isNot(contains('menit')),
        reason: 'Tanpa estimasi, isi tidak boleh menyebut "menit" (akan '
            'menampilkan angka kosong seperti "±null menit").',
      );
      expect(
        c.title,
        isNot(contains('#')),
        reason: 'orderId null -> tidak boleh muncul "#" menggantung. '
            'Bila muncul: suffix dibentuk tanpa memeriksa null/kosong.',
      );
    });

    test('orderId kosong tidak memunculkan tanda #', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.diproses,
        orderId: '',
      );
      expect(
        c.title,
        isNot(contains('#')),
        reason: 'INPUT orderId="" -> HARAP tanpa "#". Bila muncul: '
            'pengecekan isEmpty belum ada (hanya null).',
      );
    });
  });

  group('buildOrderStatusContent - Selesai', () {
    test('judul & isi sesuai', () {
      final NotificationContent c = buildOrderStatusContent(
        OrderStatus.selesai,
        orderId: 'CC-3',
      );
      expect(
        c.title,
        'Pesanan #CC-3 Selesai',
        reason: 'INPUT selesai + orderId CC-3 -> HARAP judul persis ini. '
            'Bila beda: spasi sebelum # atau kapitalisasi berubah.',
      );
      expect(
        c.body,
        contains('Terima kasih'),
        reason: 'Notifikasi selesai harus berisi ucapan terima kasih.',
      );
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
      expect(
        map['Perangkat'],
        'samsung SM-A525F',
        reason: 'HARAP "Perangkat" = "<manufacturer> <model>". '
            'Bila hanya model: manufacturer tidak digabung.',
      );
      expect(
        map['Versi Android'],
        'Android 13 (API 33)',
        reason: 'HARAP "Android 13 (API 33)". Bila tanpa "(API 33)": '
            'sdkInt tidak dipakai pada label.',
      );
      expect(
        map['Login terakhir'],
        '05/01/2026 09:07',
        reason: 'HARAP format dd/MM/yyyy HH:mm dua digit. '
            'Bila "5/1/2026 9:7": padding nol belum diterapkan.',
      );
    });

    test('data kosong tidak menghasilkan entri kosong', () {
      final DeviceSummary s = DeviceSummary.fromRaw(
        manufacturer: '  ',
        model: '',
        now: DateTime(2026, 2, 1),
      );
      expect(
        s.displayed.any((DeviceInfoEntry e) => e.label == 'Perangkat'),
        isFalse,
        reason: 'INPUT manufacturer/model hanya spasi -> entri "Perangkat" '
            'tidak boleh dibuat. Bila ada: filter nilai kosong belum jalan.',
      );
      expect(
        s.displayed.every((DeviceInfoEntry e) => e.value.trim().isNotEmpty),
        isTrue,
        reason: 'Tidak boleh ada baris dengan nilai kosong di UI, karena '
            'tampil sebagai label menggantung.',
      );
    });

    test('token panjang dipotong', () {
      final DeviceSummary s = DeviceSummary.fromRaw(
        fcmToken: 'abcdefghijklmnopqrstuvwxyz',
        now: DateTime(2026, 1, 1),
      );
      final String token = s.displayed
          .firstWhere((DeviceInfoEntry e) => e.label == 'Token notifikasi')
          .value;
      expect(
        token,
        contains('…'),
        reason: 'Token panjang HARAP dipotong dengan elipsis "…". '
            'Bila utuh: _shortToken tidak dipanggil.',
      );
      expect(
        token.length < 27,
        isTrue,
        reason: 'HARAP token dipotong menjadi 8 + 1 + 6 = 15 karakter. '
            'Bila >26: batas panjang pada _shortToken berubah.',
      );
    });
  });

  group('Formatters', () {
    test('formatRupiah memberi pemisah ribuan', () {
      expect(
        formatRupiah(15000),
        'Rp15.000',
        reason: 'INPUT 15000 -> HARAP "Rp15.000". Bila "Rp 15.000": '
            'ada spasi setelah Rp. Bila "15000": format tidak dipakai.',
      );
      expect(
        formatRupiah(500),
        'Rp500',
        reason: 'INPUT 500 -> HARAP tanpa pemisah karena < 1000.',
      );
      expect(
        formatRupiah(1234567),
        'Rp1.234.567',
        reason: 'INPUT 1234567 -> HARAP dua pemisah ribuan. '
            'Bila "Rp1.234.567,00": desimal tidak diharapkan di sini.',
      );
      expect(
        formatRupiah(0),
        'Rp0',
        reason: 'INPUT 0 -> HARAP "Rp0", bukan "Rp" saja atau string kosong.',
      );
    });

    test('formatEstimasiMenit di bawah satu jam', () {
      expect(
        formatEstimasiMenit(13),
        '13 menit',
        reason: 'INPUT 13 -> HARAP "13 menit". Bila "0 jam 13 menit": '
            'cabang < 60 tidak dipakai.',
      );
    });

    test('formatEstimasiMenit satu jam lebih', () {
      expect(
        formatEstimasiMenit(65),
        '1 jam 5 menit',
        reason: 'INPUT 65 -> HARAP "1 jam 5 menit". Bila "65 menit": '
            'konversi jam belum ada.',
      );
      expect(
        formatEstimasiMenit(120),
        '2 jam',
        reason: 'INPUT 120 -> HARAP "2 jam" tanpa "0 menit". '
            'Bila "2 jam 0 menit": sisa nol tidak dibuang.',
      );
    });
  });
}
