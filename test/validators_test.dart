import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/user_model.dart';
import 'package:tubes_perak/services/auth_service.dart';

// ============================================================================
// UNIT TEST — validasi autentikasi (kode asli: lib/services/auth_service.dart)
//
// AuthService memakai `useDemoMode = true`, sehingga aturan validasi bisa diuji
// tanpa server MySQL dan tanpa plugin native.
//
// Cara membaca kegagalan:
//   "Expected: throws <Instance of 'AuthException'>" -> aturan validasi hilang.
//   Setiap expect memakai `reason:` berisi INPUT -> HARAPAN -> PENYEBAB UMUM.
// ============================================================================

void main() {
  group('AuthService.login', () {
    test('akun demo yang benar mengembalikan user + token', () async {
      final AuthService auth = AuthService();

      final UserModel user = await auth.login(
        email: 'mahasiswa@untan.ac.id',
        password: '123456',
      );

      expect(
        user.email,
        'mahasiswa@untan.ac.id',
        reason: 'INPUT kredensial akun demo -> HARAP login berhasil.',
      );
      expect(
        user.token,
        isNotNull,
        reason: 'Login sukses harus menghasilkan token sesi.',
      );
    });

    test('email dinormalisasi (spasi & huruf besar diabaikan)', () async {
      final AuthService auth = AuthService();

      final UserModel user = await auth.login(
        email: '  MAHASISWA@UNTAN.AC.ID  ',
        password: '123456',
      );

      expect(
        user.nim,
        'H1101231001',
        reason: 'INPUT email berspasi + kapital -> HARAP tetap cocok. '
            'Bila AuthException: trim/toLowerCase belum dipakai.',
      );
    });

    test('password salah ditolak', () async {
      final AuthService auth = AuthService();

      expect(
        () => auth.login(email: 'mahasiswa@untan.ac.id', password: 'salah'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Email atau password salah.',
          ),
        ),
        reason: 'INPUT password salah -> HARAP AuthException dengan pesan jelas.',
      );
    });

    test('email tidak terdaftar ditolak', () async {
      final AuthService auth = AuthService();

      expect(
        () => auth.login(email: 'tidakada@untan.ac.id', password: '123456'),
        throwsA(isA<AuthException>()),
        reason: 'INPUT email asing -> HARAP AuthException, bukan user palsu.',
      );
    });
  });

  group('AuthService.register', () {
    test('akun baru berhasil dibuat dan NIM jadi huruf besar', () async {
      final AuthService auth = AuthService();

      final UserModel user = await auth.register(
        nim: 'h1101239999',
        nama: '  Mahasiswa Baru  ',
        email: 'Baru@Untan.ac.id',
        password: '123456',
      );

      expect(
        user.nim,
        'H1101239999',
        reason: 'INPUT nim huruf kecil -> HARAP disimpan KAPITAL.',
      );
      expect(
        user.nama,
        'Mahasiswa Baru',
        reason: 'Nama harus di-trim dari spasi berlebih.',
      );
      expect(
        user.email,
        'baru@untan.ac.id',
        reason: 'Email harus di-trim dan di-lowercase.',
      );
    });

    test('email yang sudah terdaftar ditolak', () async {
      final AuthService auth = AuthService();

      expect(
        () => auth.register(
          nim: 'H1101238888',
          nama: 'Duplikat',
          email: 'mahasiswa@untan.ac.id',
          password: '123456',
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Email sudah terdaftar. Silakan login.',
          ),
        ),
        reason: 'INPUT email yang sudah ada -> HARAP ditolak, '
            'bukan menimpa akun lama.',
      );
    });
  });
}
