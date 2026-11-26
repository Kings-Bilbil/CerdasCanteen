import 'package:flutter_test/flutter_test.dart';
import 'fixtures/utils/queue_estimator.dart';

// ============================================================================
// FILE TEST: estimasi waktu antrean (Tugas 13 - TDD)
//
// Rumus yang diuji : waktu = (antrean x 3) + (item x 2) menit
//
// CATATAN PENTING: 5 test di file ini adalah test yang sama dengan yang dipakai
// saat membuat bukti RED/GREEN di docs/tdd/*.log (nama test & jumlah tidak
// diubah, hanya ditambah `reason:`). Jangan mengubah/menghapus test di sini
// tanpa memperbarui log TDD, karena log itu bukti urutan test-dulu.
//
// Cara membaca kegagalan:
//   - "Expected: <x> Actual: <y>"                    -> rumus/konstanta salah.
//   - "Expected: throws ... Actual: returned <n>"    -> validasi belum ada.
//   - "UnimplementedError"                           -> fase RED, bukan bug.
//
// Setiap expect memakai `reason:` berisi
// INPUT -> HARAPAN -> KEMUNGKINAN PENYEBAB, supaya tester langsung tahu
// apa yang salah tanpa harus membuka kode.
// ============================================================================

void main() {
  group('estimateWaitMinutes - rumus', () {
    test('antrean kosong, 1 item = 2 menit', () {
      expect(
        estimateWaitMinutes(queueLength: 0, itemCount: 1),
        2,
        reason: 'INPUT queueLength=0, itemCount=1 -> HARAP 2 menit '
            '(0*3 + 1*2). Bila gagal: cek konstanta minutesPerQueue / '
            'minutesPerItem atau rumus di lib/utils/queue_estimator.dart.',
      );
    });

    test('3 antrean, 2 item = 13 menit', () {
      expect(
        estimateWaitMinutes(queueLength: 3, itemCount: 2),
        13,
        reason: 'INPUT queueLength=3, itemCount=2 -> HARAP 13 menit '
            '(3*3 + 2*2). Bila dapat 12: minutesPerItem berubah/dibulatkan; '
            'bila dapat 15: minutesPerQueue berubah menjadi 4.',
      );
    });
  });

  group('estimateWaitMinutes - validasi', () {
    test('antrean negatif melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: -1, itemCount: 1),
        throwsArgumentError,
        reason: 'INPUT queueLength=-1 -> HARAP ArgumentError. '
            'Bila gagal dengan "returned <-1>": pengecekan '
            '"queueLength < 0" belum ada atau terhapus.',
      );
    });

    test('item negatif melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: 1, itemCount: -1),
        throwsArgumentError,
        reason: 'INPUT itemCount=-1 -> HARAP ArgumentError. '
            'Bila gagal: kondisi "itemCount < 0" belum digabung ke '
            'pengecekan nilai negatif.',
      );
    });

    test('pesanan kosong (0 item) melempar ArgumentError', () {
      expect(
        () => estimateWaitMinutes(queueLength: 2, itemCount: 0),
        throwsArgumentError,
        reason: 'INPUT itemCount=0 -> HARAP ArgumentError karena pesanan '
            'kosong tidak boleh menghasilkan estimasi. Bila gagal dengan '
            '"returned <6>": blok "if (itemCount == 0)" belum ada.',
      );
    });
  });
}
