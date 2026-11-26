import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures/utils/validators.dart';

// ============================================================================
// WIDGET TEST — validasi form email
//
// File ini TIDAK mengimpor `lib/screens/**`, jadi tetap bisa dijalankan di
// FlutLab sebelum layar login/register dibuat Anggota 1. Widget Form dirakit
// langsung di dalam test dan memakai `Validators.email` yang asli.
//
// Cara membaca kegagalan:
//   "Expected: exactly one matching node ... Actual: zero"
//     -> pesan validasi tidak dirender. Cek `validator:` masih dipasang.
//   "Bad state: No element" pada find.byKey -> key berubah/hilang.
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
          '"Email wajib diisi" tampil. Bila tidak muncul: validator belum '
          'terpasang, atau tombol tidak memanggil FormState.validate().',
    );
    expect(
      find.textContaining('Status:'),
      findsNothing,
      reason: 'Form tidak valid -> submit TIDAK boleh diteruskan. '
          'Bila "Status: terkirim" muncul: validate() diabaikan.',
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
          'Bila "Email wajib diisi": enterText gagal / controller tidak '
          'terhubung.',
    );
  });
}
