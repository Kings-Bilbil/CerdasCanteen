import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/utils/queue_estimator.dart';

void main() {
  group('estimateWaitMinutes - rumus', () {
    test('antrean kosong, 1 item = 2 menit', () {
      expect(estimateWaitMinutes(queueLength: 0, itemCount: 1), 2);
    });

    test('3 antrean, 2 item = 13 menit', () {
      expect(estimateWaitMinutes(queueLength: 3, itemCount: 2), 13);
    });
  });

  group('estimateWaitMinutes - validasi', () {
    test('antrean negatif melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: -1, itemCount: 1),
        throwsArgumentError,
      );
    });

    test('item negatif melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: 1, itemCount: -1),
        throwsArgumentError,
      );
    });

    test('pesanan kosong (0 item) melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: 2, itemCount: 0),
        throwsArgumentError,
      );
    });
  });
}
