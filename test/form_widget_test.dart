import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tubes_perak/providers/auth_provider.dart';
import 'package:tubes_perak/screens/login_screen.dart';

// ============================================================================
// WIDGET TEST — form login asli (lib/screens/login_screen.dart)
//
// Yang diuji: aturan validasi Form milik layar login, bukan form tiruan.
// AuthProvider disuntikkan lewat Provider agar layar bisa dirender.
//
// Cara membaca kegagalan:
//   "Expected: exactly one matching node ... Actual: zero"
//     -> pesan validasi tidak muncul. Cek urutan validator di LoginScreen.
//   "Bad state: No element" pada find.byType
//     -> struktur layar berubah (mis. TextFormField diganti widget lain).
// ============================================================================

Widget _buildLoginScreen() {
  return ChangeNotifierProvider<AuthProvider>(
    create: (_) => AuthProvider(),
    child: const MaterialApp(home: LoginScreen()),
  );
}

Finder _fieldByLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
}

void main() {
  testWidgets('email dikosongkan memunculkan pesan wajib diisi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginScreen());

    // Field terisi default; kosongkan dulu.
    await tester.enterText(_fieldByLabel('Email Mahasiswa'), '');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(
      find.text('Email wajib diisi'),
      findsOneWidget,
      reason: 'INPUT email kosong + tekan Masuk -> HARAP pesan '
          '"Email wajib diisi" tampil. Bila tidak: validator email hilang '
          'atau tombol tidak memanggil FormState.validate().',
    );
  });

  testWidgets('email tanpa @ memunculkan pesan format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginScreen());

    await tester.enterText(_fieldByLabel('Email Mahasiswa'), 'tanpa-at');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(
      find.text('Format email tidak valid'),
      findsOneWidget,
      reason: 'INPUT "tanpa-at" -> HARAP pesan format. '
          'Bila "Email wajib diisi": enterText gagal / controller salah.',
    );
  });

  testWidgets('password kurang dari 6 karakter ditolak', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginScreen());

    await tester.enterText(_fieldByLabel('Password'), '123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(
      find.text('Password minimal 6 karakter'),
      findsOneWidget,
      reason: 'INPUT password "123" -> HARAP pesan minimal 6 karakter. '
          'Bila tidak muncul: batas panjang password berubah.',
    );
  });

  testWidgets('form kosong tidak memanggil proses login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginScreen());

    await tester.enterText(_fieldByLabel('Email Mahasiswa'), '');
    await tester.enterText(_fieldByLabel('Password'), '');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    // Validasi gagal -> isLoading tidak pernah aktif, jadi masih di halaman login.
    expect(
      find.byType(LoginScreen),
      findsOneWidget,
      reason: 'Form tidak valid -> HARAP tetap di LoginScreen. '
          'Bila pindah halaman: validate() dilewati sebelum login().',
    );
    expect(
      find.text('Password wajib diisi'),
      findsOneWidget,
      reason: 'Pesan untuk password kosong harus tampil bersamaan.',
    );
  });
}
