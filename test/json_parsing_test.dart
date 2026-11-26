import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/menu_item.dart';
import 'package:tubes_perak/models/transaksi.dart';
import 'package:tubes_perak/models/user_model.dart';

// ============================================================================
// UNIT TEST — parsing JSON (kode asli: lib/models/menu_item.dart,
// lib/models/transaksi.dart, lib/models/user_model.dart)
//
// Cara membaca kegagalan:
//   "Expected: <...> Actual: <...>" -> nama key JSON berubah / fallback salah.
//   Setiap expect memakai `reason:` berisi INPUT -> HARAPAN -> PENYEBAB UMUM.
// ============================================================================

void main() {
  group('MenuItem.fromJson - format aplikasi', () {
    test('membaca seluruh field apa adanya', () {
      final MenuItem menu = MenuItem.fromJson(<String, dynamic>{
        'id': 7,
        'nama': 'Nasi Lemak',
        'harga': 12000,
        'imageUrl': 'https://contoh/gambar.jpg',
        'kategori': 'Makanan',
        'deskripsi': 'Nasi dengan sambal',
        'rating': 4.7,
      });

      expect(menu.id, 7, reason: 'INPUT id=7 -> HARAP id 7.');
      expect(menu.nama, 'Nasi Lemak', reason: 'Nama harus terbaca utuh.');
      expect(menu.harga, 12000, reason: 'Harga int harus jadi double 12000.');
      expect(menu.kategori, 'Makanan', reason: 'Kategori harus terbaca.');
      expect(
        menu.rating,
        4.7,
        reason: 'Rating harus terbaca sebagai double.',
      );
    });

    test('harga berupa teks angka tetap diparse', () {
      final MenuItem menu = MenuItem.fromJson(<String, dynamic>{
        'id': 1,
        'nama': 'Mie',
        'harga': '9500',
      });

      expect(
        menu.harga,
        9500,
        reason: 'INPUT harga="9500" (String) -> HARAP 9500. '
            'Bila 8000: double.tryParse gagal lalu jatuh ke harga simulasi.',
      );
    });
  });

  group('MenuItem.fromJson - format TheMealDB', () {
    test('memakai alias idMeal/strMeal/strCategory', () {
      final MenuItem menu = MenuItem.fromJson(<String, dynamic>{
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strMealThumb': 'https://contoh/thumb.jpg',
        'strInstructions': 'Langkah satu\r\nLangkah dua',
      });

      expect(
        menu.id,
        52772,
        reason: 'INPUT idMeal="52772" -> HARAP 52772. '
            'Bila 0: key idMeal tidak dibaca.',
      );
      expect(
        menu.nama,
        'Teriyaki Chicken Casserole',
        reason: 'Alias strMeal harus dipakai saat key nama tidak ada.',
      );
      expect(
        menu.kategori,
        'Chicken',
        reason: 'Alias strCategory harus dipakai.',
      );
      expect(
        menu.deskripsi.contains('\n') && !menu.deskripsi.contains('\r'),
        isTrue,
        reason: 'INPUT \\r\\n -> HARAP dinormalkan jadi \\n saja.',
      );
    });

    test('tanpa harga & rating memakai nilai simulasi deterministik', () {
      final MenuItem menu = MenuItem.fromJson(<String, dynamic>{
        'idMeal': '1',
        'strMeal': 'Menu Uji',
      });

      expect(
        menu.harga,
        MenuItem.hitungHargaSimulasi(1),
        reason: 'Tanpa key harga -> HARAP hitungHargaSimulasi(id).',
      );
      expect(
        menu.rating,
        MenuItem.hitungRatingSimulasi(1),
        reason: 'Tanpa key rating -> HARAP hitungRatingSimulasi(id).',
      );
      expect(
        menu.harga >= 8000 && menu.harga <= 35000,
        isTrue,
        reason: 'Harga simulasi harus di rentang 8000..35000.',
      );
    });

    test('JSON kosong tetap menghasilkan objek aman (tidak crash)', () {
      final MenuItem menu = MenuItem.fromJson(<String, dynamic>{});

      expect(
        menu.nama,
        'Menu Kantin',
        reason: 'JSON kosong -> HARAP nama fallback "Menu Kantin".',
      );
      expect(
        menu.kategori,
        'Makanan',
        reason: 'JSON kosong -> HARAP kategori fallback "Makanan".',
      );
      expect(
        menu.deskripsi.isNotEmpty,
        isTrue,
        reason: 'Deskripsi kosong harus diganti teks default.',
      );
    });
  });

  group('MenuItem.toMap', () {
    test('hasil toMap bisa dibaca ulang oleh fromJson', () {
      final MenuItem asli = MenuItem.fromJson(<String, dynamic>{
        'id': 3,
        'nama': 'Sate',
        'harga': 18000,
        'kategori': 'Makanan',
        'rating': 4.5,
      });
      final MenuItem ulang = MenuItem.fromJson(asli.toMap());

      expect(ulang.id, asli.id, reason: 'Round-trip harus menjaga id.');
      expect(ulang.nama, asli.nama, reason: 'Round-trip harus menjaga nama.');
      expect(
        ulang.harga,
        asli.harga,
        reason: 'Round-trip harus menjaga harga.',
      );
    });
  });

  group('Transaksi.fromMap', () {
    test('membaca baris SQLite dan mengubah tipe data', () {
      final Transaksi trx = Transaksi.fromMap(<String, dynamic>{
        'id': '12',
        'kode_pesanan': 'CC-001',
        'ringkasan_item': '2x Nasi Goreng',
        'total': '45000',
        'status': 'Siap Diambil',
        'waktu': '2026-11-26T10:30:00.000',
      });

      expect(
        trx.id,
        12,
        reason: 'INPUT id="12" (String dari SQLite) -> HARAP int 12.',
      );
      expect(
        trx.total,
        45000.0,
        reason: 'INPUT total="45000" -> HARAP double 45000.',
      );
      expect(
        trx.status,
        'Siap Diambil',
        reason: 'Status harus terbaca apa adanya.',
      );
      expect(
        trx.waktu.year,
        2026,
        reason: 'Waktu ISO-8601 harus diparse, bukan diganti DateTime.now().',
      );
    });

    test('field hilang memakai nilai default, tidak crash', () {
      final Transaksi trx = Transaksi.fromMap(<String, dynamic>{});

      expect(
        trx.kodePesanan,
        '',
        reason: 'Kode pesanan hilang -> HARAP string kosong.',
      );
      expect(
        trx.status,
        'Diproses',
        reason: 'Status hilang -> HARAP default "Diproses".',
      );
      expect(
        trx.total,
        0.0,
        reason: 'Total hilang -> HARAP 0.0, bukan null/error.',
      );
    });

    test('toMap tidak menulis id saat null (biar AUTOINCREMENT jalan)', () {
      final Transaksi trx = Transaksi(
        kodePesanan: 'CC-002',
        ringkasanItem: '1x Es Teh',
        total: 5000,
        status: 'Diproses',
        waktu: DateTime(2026, 11, 26),
      );

      expect(
        trx.toMap().containsKey('id'),
        isFalse,
        reason: 'id null -> HARAP key id tidak ada. '
            'Bila ada: SQLite menganggap id=null dan insert bisa gagal.',
      );
      expect(
        trx.toMap()['kode_pesanan'],
        'CC-002',
        reason: 'Nama kolom harus snake_case sesuai skema tabel.',
      );
    });
  });

  group('UserModel.fromJson', () {
    test('membaca akun hasil login', () {
      final UserModel user = UserModel.fromJson(
        jsonDecode(
              '{"id":1,"nim":"H1101231001","nama":"Mahasiswa Demo",'
              '"email":"mahasiswa@untan.ac.id","token":"abc"}',
            )
            as Map<String, dynamic>,
      );

      expect(user.id, 1, reason: 'id harus terbaca sebagai int.');
      expect(
        user.nama,
        'Mahasiswa Demo',
        reason: 'nama harus terbaca utuh.',
      );
      expect(user.token, 'abc', reason: 'token harus tersimpan.');
    });

    test('field hilang memakai fallback aman', () {
      final UserModel user = UserModel.fromJson(<String, dynamic>{});

      expect(
        user.id,
        0,
        reason: 'id hilang -> HARAP 0. '
            'Bila crash: json["id"] dipakai tanpa null-check.',
      );
      expect(
        user.nim,
        '-',
        reason: 'nim hilang -> HARAP "-".',
      );
      expect(
        user.nama,
        'Mahasiswa',
        reason: 'nama hilang -> HARAP "Mahasiswa".',
      );
      expect(user.token, isNull, reason: 'token hilang -> HARAP null.');
    });
  });
}
