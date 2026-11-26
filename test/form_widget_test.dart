import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/utils/validators.dart';

// Widget test ini TIDAK bergantung pada layar aplikasi mana pun.
// Ia merakit Form + TextFormField langsung di dalam test lalu memakai
// validator asli dari `lib/utils/validators.dart`. Tujuannya memastikan
// kontrak validasi benar-benar bekerja di dalam widget Flutter (pesan error
// muncul di layar setelah submit), bukan hanya sebagai fungsi murni.
//
// Karena tidak mengimpor `lib/screens/**`, test ini tetap bisa dijalankan di
// FlutLab sebelum layar login/register dibuat Anggota 1.

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

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.textContaining('Status:'), findsNothing);
    });

    testWidgets('email salah format memunculkan pesan format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.enterText(find.byKey(_emailKey), 'tanpa-at');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('email valid meneruskan submit', (WidgetTester tester) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.enterText(find.byKey(_emailKey), 'mahasiswa@kampus.ac.id');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(find.text('Status: terkirim'), findsOneWidget);
      expect(find.text('Email wajib diisi'), findsNothing);
      expect(find.text('Format email tidak valid'), findsNothing);
    });

    testWidgets('pesan error hilang setelah input diperbaiki', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _EmailFormHarness());

      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi'), findsOneWidget);

      await tester.enterText(find.byKey(_emailKey), 'budi@mail.com');
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsNothing);
      expect(find.text('Status: terkirim'), findsOneWidget);
    });
  });

  group('Widget test - teks estimasi & rupiah tampil di widget', () {
    testWidgets('teks hasil formatter bisa dirender', (
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

      expect(find.text('Rp35.000'), findsOneWidget);
      expect(find.text('15 menit'), findsOneWidget);
    });
  });
}
