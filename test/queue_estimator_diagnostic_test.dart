import 'package:flutter_test/flutter_test.dart';
import 'fixtures/utils/queue_estimator.dart';

// ============================================================================
// FILE TEST: diagnosa tambahan estimasi antrean
//
// File ini BUKAN bagian bukti RED/GREEN (lihat test/queue_estimator_test.dart).
// Tujuannya menangkap regresi yang tidak terlihat dari 5 test inti:
//   - konstanta berubah diam-diam
//   - rumus tidak linear (ada pembulatan / cabang tersembunyi)
//   - pesan error berubah sehingga sulit didiagnosis
//
// Kalau file ini merah tapi queue_estimator_test.dart hijau, artinya perilaku
// masih "lulus contoh" tetapi aturan umumnya sudah bergeser.
// ============================================================================

void main() {
  group('diagnosa - konstanta', () {
    test('minutesPerQueue masih 3 menit per orang', () {
      expect(
        minutesPerQueue,
        3,
        reason: 'Konstanta minutesPerQueue dipakai rumus dan dokumen '
            '(docs/Variabel.md §1). Bila sengaja diubah, perbarui '
            'docs/Variabel.md, tabel analisis di docs/analisis_tugas13.md, '
            'dan test rumus 3 antrean = 13 menit.',
      );
    });

    test('minutesPerItem masih 2 menit per item', () {
      expect(
        minutesPerItem,
        2,
        reason: 'Konstanta minutesPerItem dipakai rumus dan dokumen. '
            'Bila diubah, test "antrean kosong, 1 item = 2 menit" juga '
            'harus diperbarui — keduanya satu paket.',
      );
    });
  });

  group('diagnosa - sifat rumus', () {
    test('estimasi bertambah linear terhadap panjang antrean', () {
      final int satu = estimateWaitMinutes(queueLength: 1, itemCount: 1);
      final int empat = estimateWaitMinutes(queueLength: 4, itemCount: 1);

      expect(
        empat - satu,
        3 * minutesPerQueue,
        reason: 'INPUT antrean 1 vs 4 (selisih 3 orang), item tetap 1. '
            'HARAP selisih = 3 x minutesPerQueue = 9 menit. '
            'Bila gagal: rumus tidak linear, misalnya ada pembulatan, '
            'batas maksimum, atau cabang khusus di queue_estimator.',
      );
    });

    test('estimasi bertambah linear terhadap jumlah item', () {
      final int satu = estimateWaitMinutes(queueLength: 2, itemCount: 1);
      final int lima = estimateWaitMinutes(queueLength: 2, itemCount: 5);

      expect(
        lima - satu,
        4 * minutesPerItem,
        reason: 'INPUT item 1 vs 5 (selisih 4 item), antrean tetap 2. '
            'HARAP selisih = 4 x minutesPerItem = 8 menit. '
            'Bila gagal: ada pengabaian item atau pembulatan per item.',
      );
    });

    test('antrean 0 dengan item banyak tidak menghasilkan nilai negatif', () {
      final int hasil = estimateWaitMinutes(queueLength: 0, itemCount: 10);

      expect(
        hasil,
        10 * minutesPerItem,
        reason: 'INPUT queueLength=0, itemCount=10 -> HARAP 20 menit. '
            'Bila gagal: kemungkinan ada pengurangan/prioritas yang membuat '
            'estimasi turun saat antrean kosong.',
      );
      expect(
        hasil,
        greaterThan(0),
        reason: 'Estimasi pesanan yang sah tidak boleh 0 menit; UI akan '
            'menampilkan "0 menit" dan terlihat seperti bug.',
      );
    });
  });

  group('diagnosa - pesan error bisa ditelusuri', () {
    test('pesan untuk nilai negatif menyebut "negatif"', () {
      expect(
        () => estimateWaitMinutes(queueLength: -1, itemCount: 1),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            contains('negatif'),
          ),
        ),
        reason: 'Pesan error dipakai untuk menjelaskan penyebab ke tester '
            'dan (nanti) ke pengguna. Bila gagal: teks ArgumentError diubah.',
      );
    });

    test('pesan untuk pesanan kosong menyebut "minimal 1 item"', () {
      expect(
        () => estimateWaitMinutes(queueLength: 2, itemCount: 0),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            contains('minimal 1 item'),
          ),
        ),
        reason: 'Pesan harus membedakan "pesanan kosong" dari "nilai '
            'negatif", supaya tester tahu aturan mana yang dilanggar.',
      );
    });

    test('nilai negatif ditolak sebelum aturan pesanan kosong', () {
      expect(
        () => estimateWaitMinutes(queueLength: -5, itemCount: 0),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            contains('negatif'),
          ),
        ),
        reason: 'INPUT antrean=-5 DAN item=0 (dua pelanggaran sekaligus). '
            'HARAP pesan "negatif" muncul lebih dulu agar penyebab utama '
            'tidak tertutup oleh aturan kedua. Bila gagal: urutan '
            'pengecekan di queue_estimator tertukar.',
      );
    });
  });
}
