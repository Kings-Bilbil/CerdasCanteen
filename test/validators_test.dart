import 'package:flutter_test/flutter_test.dart';
import 'fixtures/utils/validators.dart';

// ============================================================================
// FILE TEST: validasi form login/register + aturan checkout
//
// Cara membaca kegagalan:
//   - "Expected: 'Email wajib diisi' Actual: null" -> validasi hilang.
//   - "Actual: <teks lain>" -> teks pesan diubah, UI ikut berubah.
//
// Teks pesan di file ini SAMA PERSIS dengan yang tampil di UI. Kalau ingin
// mengganti kalimat, ubah test ini dan docs/Variabel.md §5 bersamaan.
// ============================================================================

void main() {
  group('Validators.email', () {
    test('email valid tidak menghasilkan error', () {
      expect(
        Validators.email('mahasiswa@kampus.ac.id'),
        isNull,
        reason: 'INPUT email kampus valid -> HARAP null. Bila ada pesan '
            'error: regex terlalu ketat (mis. menolak titik di domain).',
      );
      expect(
        Validators.email('  budi.s@mail.com  '),
        isNull,
        reason: 'INPUT email dengan spasi di awal/akhir -> HARAP null. '
            'Bila error: input belum di-trim sebelum divalidasi.',
      );
    });

    test('email kosong ditolak', () {
      expect(
        Validators.email(''),
        'Email wajib diisi',
        reason: 'INPUT string kosong -> HARAP "Email wajib diisi". '
            'Bila null: field kosong lolos dan login bisa dikirim kosong.',
      );
      expect(
        Validators.email(null),
        'Email wajib diisi',
        reason: 'INPUT null -> HARAP pesan wajib diisi, bukan crash. '
            'Bila TypeError: parameter tidak ditangani sebagai nullable.',
      );
      expect(
        Validators.email('   '),
        'Email wajib diisi',
        reason: 'INPUT hanya spasi -> HARAP pesan wajib diisi. '
            'Bila "Format email tidak valid": trim belum dilakukan lebih dulu.',
      );
    });

    test('format email salah ditolak', () {
      expect(
        Validators.email('tanpa-at'),
        'Format email tidak valid',
        reason: 'INPUT tanpa @ -> HARAP format tidak valid.',
      );
      expect(
        Validators.email('budi@'),
        'Format email tidak valid',
        reason: 'INPUT domain kosong -> HARAP format tidak valid. '
            'Bila lolos: regex tidak mewajibkan bagian setelah @.',
      );
      expect(
        Validators.email('budi@kampus'),
        'Format email tidak valid',
        reason: 'INPUT domain tanpa titik -> HARAP format tidak valid. '
            'Bila lolos: regex tidak mewajibkan titik pada domain.',
      );
    });
  });

  group('Validators.password', () {
    test('password >= 8 karakter lolos', () {
      expect(
        Validators.password('rahasia123'),
        isNull,
        reason: 'INPUT 11 karakter -> HARAP null (batas minimum 8).',
      );
    });

    test('password kosong ditolak', () {
      expect(
        Validators.password(''),
        'Password wajib diisi',
        reason: 'INPUT kosong -> HARAP pesan wajib diisi. '
            'Bila "minimal 8 karakter": urutan pengecekan kosong tertukar.',
      );
    });

    test('password kurang dari 8 karakter ditolak', () {
      expect(
        Validators.password('1234567'),
        'Password minimal 8 karakter',
        reason: 'INPUT 7 karakter -> HARAP pesan minimal 8. '
            'Bila null: batas panjang berubah menjadi 7 atau dihapus.',
      );
    });
  });

  group('Validators.nama', () {
    test('nama valid lolos', () {
      expect(
        Validators.nama('Budi'),
        isNull,
        reason: 'INPUT 4 karakter -> HARAP null (batas minimum 3).',
      );
    });

    test('nama kosong/spasi ditolak', () {
      expect(
        Validators.nama('   '),
        'Nama wajib diisi',
        reason: 'INPUT hanya spasi -> HARAP pesan wajib diisi. '
            'Bila "minimal 3 karakter": trim belum dilakukan.',
      );
    });

    test('nama terlalu pendek ditolak', () {
      expect(
        Validators.nama('Bu'),
        'Nama minimal 3 karakter',
        reason: 'INPUT 2 karakter -> HARAP pesan minimal 3. '
            'Bila null: batas panjang nama berubah.',
      );
    });
  });

  group('Validators.konfirmasiPassword', () {
    test('sama dengan password lolos', () {
      expect(
        Validators.konfirmasiPassword('rahasia123', 'rahasia123'),
        isNull,
        reason: 'INPUT dua nilai identik -> HARAP null.',
      );
    });

    test('berbeda ditolak', () {
      expect(
        Validators.konfirmasiPassword('rahasia124', 'rahasia123'),
        'Konfirmasi password tidak sama',
        reason: 'INPUT beda 1 karakter -> HARAP pesan tidak sama. '
            'Bila null: perbandingan tidak dilakukan / case-insensitive.',
      );
    });

    test('kosong ditolak', () {
      expect(
        Validators.konfirmasiPassword('', 'rahasia123'),
        'Konfirmasi password wajib diisi',
        reason: 'INPUT kosong -> HARAP pesan wajib diisi, bukan "tidak sama". '
            'Bila "tidak sama": pengecekan kosong tidak ada.',
      );
    });
  });

  group('Validators.isFormValid', () {
    test('semua null berarti valid', () {
      expect(
        Validators.isFormValid(<String?>[null, null]),
        isTrue,
        reason: 'INPUT daftar tanpa error -> HARAP true. '
            'Bila false: fungsi memakai any() bukan every().',
      );
    });

    test('ada satu error berarti tidak valid', () {
      expect(
        Validators.isFormValid(<String?>[null, 'Password wajib diisi']),
        isFalse,
        reason: 'INPUT satu error -> HARAP false. Bila true: tombol submit '
            'aktif padahal form belum lengkap.',
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
        reason: 'Pesan ini ditampilkan ke pengguna saat checkout kosong. '
            'Bila beda: ubah UI dan docs/Variabel.md §5 bersamaan.',
      );
    });

    test('keranjang berisi boleh checkout', () {
      expect(
        CheckoutRules.canCheckout(itemCount: 1),
        isTrue,
        reason: 'INPUT 1 item -> HARAP boleh checkout. Bila false: batas '
            'minimum berubah menjadi lebih dari 1.',
      );
      expect(
        CheckoutRules.validateCart(itemCount: 3),
        isNull,
        reason: 'INPUT 3 item -> HARAP null (tidak ada pesan error).',
      );
    });
  });
}
