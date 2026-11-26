import 'package:flutter_test/flutter_test.dart';
import 'fixtures/utils/validators.dart';

// ============================================================================
// UNIT TEST 3 — validasi form login/register + aturan checkout
//
// Cara membaca kegagalan:
//   "Expected: 'Email wajib diisi' Actual: null" -> validasi hilang.
//
// Teks pesan di file ini SAMA PERSIS dengan yang tampil di UI.
// Kalau ingin mengganti kalimat, ubah test ini dan docs/Variabel.md §5.
// ============================================================================

void main() {
  group('Validators.email', () {
    test('email valid lolos', () {
      expect(
        Validators.email('mahasiswa@kampus.ac.id'),
        isNull,
        reason: 'INPUT email valid -> HARAP null. '
            'Bila ada pesan error: regex terlalu ketat.',
      );
    });

    test('email kosong dan salah format ditolak', () {
      expect(
        Validators.email(''),
        'Email wajib diisi',
        reason: 'INPUT kosong -> HARAP "Email wajib diisi". '
            'Bila null: login bisa dikirim kosong.',
      );
      expect(
        Validators.email('tanpa-at'),
        'Format email tidak valid',
        reason: 'INPUT tanpa @ -> HARAP format tidak valid. '
            'Bila lolos: regex tidak mewajibkan @.',
      );
    });
  });

  group('Validators.password', () {
    test('batas minimal 8 karakter', () {
      expect(
        Validators.password('rahasia123'),
        isNull,
        reason: 'INPUT 11 karakter -> HARAP null (minimum 8).',
      );
      expect(
        Validators.password('1234567'),
        'Password minimal 8 karakter',
        reason: 'INPUT 7 karakter -> HARAP pesan minimal 8. '
            'Bila null: batas panjang berubah atau dihapus.',
      );
    });
  });

  group('CheckoutRules (penilaian proses sistem)', () {
    test('keranjang kosong ditolak', () {
      expect(
        CheckoutRules.canCheckout(itemCount: 0),
        isFalse,
        reason: 'INPUT itemCount=0 -> HARAP tidak boleh checkout. '
            'Bila true: pesanan kosong bisa dibuat (nilai Tugas 13 gagal).',
      );
      expect(
        CheckoutRules.validateCart(itemCount: 0),
        'Keranjang kosong, tidak bisa checkout',
        reason: 'Pesan ini tampil ke pengguna saat checkout kosong. '
            'Bila beda: ubah UI dan docs/Variabel.md §5 bersamaan.',
      );
    });

    test('keranjang berisi boleh checkout', () {
      expect(
        CheckoutRules.canCheckout(itemCount: 1),
        isTrue,
        reason: 'INPUT 1 item -> HARAP boleh checkout. '
            'Bila false: batas minimum berubah.',
      );
    });
  });
}
