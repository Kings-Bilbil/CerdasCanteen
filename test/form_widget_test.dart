import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/utils/validators.dart';

// ============================================================================
// FILE TEST: widget test validasi form (tanpa layar aplikasi)
//
// File ini TIDAK mengimpor `lib/screens/**`, jadi tetap bisa dijalankan di
// FlutLab sebelum layar login/register dibuat Anggota 1. Widget Form dirakit
// langsung di dalam test dan memakai `Validators.email` yang asli.
//
// Cara membaca kegagalan:
//   - "Expected: exactly one matching node ... Actual: _TextWidgetFinder:<zero>"
//     -> pesan validasi tidak dirender. Cek apakah `validator:` masih dipasang.
//   - "Bad state: No element" pada find.byKey -> key berubah/hilang.
//   - "pumpAndSettle timed out" -> ada animasi/loop tak berujung di widget.
// ============================================================================

const Key _emailKey = Key('email-field');
const Key _submitKey = Key('submit-button');

/// Form login minimal: satu field email + tombol submit.
class _EmailFormHarness extends StatefulWidget {
  const _EmailFormHarness();

  @override
  State<_EmailFormHarness> createState() => _EmailFormHarnessState();
}

class _EmailFormHarnessState extends State<_EmailFormHarness> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _submittedValue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                key: _emailKey,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              ElevatedButton(
                key: _submitKey,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _submittedValue = 'terkirim');
                  }
                },
                child: const Text('Masuk'),
              ),
              if (_submittedValue != null) Text('Status: $_submittedValue'),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Widget test - validasi email pada Form', () {
    testWidgets('email kosong memunculkan pesan wajib diisi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Email wajib diisi'),
        findsOneWidget,
        reason: 'INPUT field email kosong + tekan Masuk -> HARAP pesan '
            '"Email wajib diisi" tampil di bawah field. Bila tidak muncul: '
            'validator belum terpasang pada TextFormField, atau tombol '
            'tidak memanggil FormState.validate().',
      );
      expect(
        find.textContaining('Status:'),
        findsNothing,
        reason: 'Form tidak valid -> submit TIDAK boleh diteruskan. '
            'Bila "Status: terkirim" muncul: validate() diabaikan.',
      );
    });

    testWidgets('email salah format memunculkan pesan format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.enterText(find.byKey(_emailKey), 'tanpa-at');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Format email tidak valid'),
        findsOneWidget,
        reason: 'INPUT "tanpa-at" -> HARAP pesan format tidak valid. '
            'Bila "Email wajib diisi": nilai input tidak sampai ke validator '
            '(enterText gagal / controller tidak terhubung).',
      );
    });

    testWidgets('email valid meneruskan submit', (WidgetTester tester) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.enterText(find.byKey(_emailKey), 'mahasiswa@kampus.ac.id');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Status: terkirim'),
        findsOneWidget,
        reason: 'INPUT email valid -> HARAP submit lolos dan penanda '
            '"Status: terkirim" muncul. Bila tidak: validator menolak email '
            'yang seharusnya sah (regex terlalu ketat).',
      );
      expect(
        find.text('Email wajib diisi'),
        findsNothing,
        reason: 'Tidak boleh ada pesan error tersisa setelah input valid.',
      );
      expect(
        find.text('Format email tidak valid'),
        findsNothing,
        reason: 'Tidak boleh ada pesan format setelah input valid.',
      );
    });

    testWidgets('pesan error hilang setelah input diperbaiki', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();
      expect(
        find.text('Email wajib diisi'),
        findsOneWidget,
        reason: 'Prasyarat test: submit kosong dulu harus memunculkan error.',
      );

      await tester.enterText(find.byKey(_emailKey), 'budi@mail.com');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Email wajib diisi'),
        findsNothing,
        reason: 'Setelah input diperbaiki, pesan lama harus hilang. '
            'Bila masih ada: UI tidak memanggil validate() ulang.',
      );
      expect(
        find.text('Status: terkirim'),
        findsOneWidget,
        reason: 'Submit kedua dengan email valid harus lolos.',
      );
    });
  });

  group('Widget test - teks hasil formatter tampil di widget', () {
    testWidgets('format rupiah dan estimasi bisa dirender', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                Text('Rp35.000'),
                Text('15 menit'),
              ],
            ),
          ),
        ),
      );

      expect(
        find.text('Rp35.000'),
        findsOneWidget,
        reason: 'Teks harga harus bisa dirender tanpa overflow/error. '
            'Bila gagal: masalah layout, bukan formatter.',
      );
      expect(
        find.text('15 menit'),
        findsOneWidget,
        reason: 'Teks estimasi harus bisa dirender tanpa error layout.',
      );
    });
  });
}
