import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('email valid tidak menghasilkan error', () {
      expect(Validators.email('mahasiswa@kampus.ac.id'), isNull);
      expect(Validators.email('  budi.s@mail.com  '), isNull);
    });

    test('email kosong ditolak', () {
      expect(Validators.email(''), 'Email wajib diisi');
      expect(Validators.email(null), 'Email wajib diisi');
      expect(Validators.email('   '), 'Email wajib diisi');
    });

    test('format email salah ditolak', () {
      expect(Validators.email('tanpa-at'), 'Format email tidak valid');
      expect(Validators.email('budi@'), 'Format email tidak valid');
      expect(Validators.email('budi@kampus'), 'Format email tidak valid');
    });
  });

  group('Validators.password', () {
    test('password >= 8 karakter lolos', () {
      expect(Validators.password('rahasia123'), isNull);
    });

    test('password kosong ditolak', () {
      expect(Validators.password(''), 'Password wajib diisi');
    });

    test('password kurang dari 8 karakter ditolak', () {
      expect(Validators.password('1234567'), 'Password minimal 8 karakter');
    });
  });

  group('Validators.nama', () {
    test('nama valid lolos', () {
      expect(Validators.nama('Budi'), isNull);
    });

    test('nama kosong/spasi ditolak', () {
      expect(Validators.nama('   '), 'Nama wajib diisi');
    });

    test('nama terlalu pendek ditolak', () {
      expect(Validators.nama('Bu'), 'Nama minimal 3 karakter');
    });
  });

  group('Validators.konfirmasiPassword', () {
    test('sama dengan password lolos', () {
      expect(Validators.konfirmasiPassword('rahasia123', 'rahasia123'), isNull);
    });

    test('berbeda ditolak', () {
      expect(Validators.konfirmasiPassword('rahasia124', 'rahasia123'),
          'Konfirmasi password tidak sama');
    });

    test('kosong ditolak', () {
      expect(Validators.konfirmasiPassword('', 'rahasia123'),
          'Konfirmasi password wajib diisi');
    });
  });

  group('Validators.isFormValid', () {
    test('semua null berarti valid', () {
      expect(Validators.isFormValid(<String?>[null, null]), isTrue);
    });

    test('ada satu error berarti tidak valid', () {
      expect(
        Validators.isFormValid(<String?>[null, 'Password wajib diisi']),
        isFalse,
      );
    });
  });

  group('CheckoutRules (penilaian proses sistem)', () {
    test('keranjang kosong ditolak', () {
      expect(CheckoutRules.canCheckout(itemCount: 0), isFalse);
      expect(CheckoutRules.validateCart(itemCount: 0),
          'Keranjang kosong, tidak bisa checkout');
    });

    test('keranjang berisi boleh checkout', () {
      expect(CheckoutRules.canCheckout(itemCount: 1), isTrue);
      expect(CheckoutRules.validateCart(itemCount: 3), isNull);
    });
  });
}
