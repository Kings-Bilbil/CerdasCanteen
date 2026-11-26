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
}
