// lib/services/db_helper.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/transaksi.dart';

/// Exception khusus saat SQLite dipanggil pada platform Web (mis. Web Preview FlutLab),
/// karena package `sqflite` hanya berjalan pada Android, iOS, dan macOS.
class DbWebNotSupportedException implements Exception {
  final String message;

  const DbWebNotSupportedException([
    this.message =
        'SQLite (sqflite) tidak berjalan di Web Preview FlutLab. '
        'Untuk menguji penyimpanan database permanen, build Android APK di FlutLab '
        'lalu jalankan di HP Android.',
  ]);

  @override
  String toString() => message;
}

/// Singleton helper untuk operasi CRUD SQLite tabel `transaksi` (Tugas 10).
/// Dipanggil Anggota 1 saat checkout berhasil (`insertTransaksi`) dan
/// dibaca/dihapus pada `HistoryScreen` milik Anggota 2.
class DbHelper {
  DbHelper._internal();

  /// Satu-satunya instance singleton DbHelper.
  static final DbHelper instance = DbHelper._internal();

  /// Factory constructor mengembalikan instance singleton yang sama.
  factory DbHelper() => instance;

  static const String _dbName = 'cerdas_canteen.db';
  static const int _dbVersion = 1;
  static const String tableTransaksi = 'transaksi';

  Database? _database;

  /// Guard kIsWeb agar tidak crash dengan pesan error tak jelas di Flutter Web.
  void _cekPlatformDidukung() {
    if (kIsWeb) {
      throw const DbWebNotSupportedException();
    }
  }

  /// Membuka atau mengembalikan koneksi database SQLite secara lazy singleton.
  Future<Database> get database async {
    _cekPlatformDidukung();
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi file database dan pembuatan tabel `transaksi`.
  Future<Database> _initDatabase() async {
    try {
      final String dbPath = await getDatabasesPath();
      final String fullPath = p.join(dbPath, _dbName);

      return await openDatabase(
        fullPath,
        version: _dbVersion,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE $tableTransaksi (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              kode_pesanan TEXT NOT NULL,
              ringkasan_item TEXT NOT NULL,
              total REAL NOT NULL,
              status TEXT NOT NULL,
              waktu TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      throw Exception('Gagal menginisialisasi database SQLite: $e');
    }
  }

  /// CREATE — Menambahkan transaksi baru ke SQLite. Mengembalikan ID baris baru.
  Future<int> insertTransaksi(Transaksi transaksi) async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      return await db.insert(
        tableTransaksi,
        transaksi.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi ke SQLite: $e');
    }
  }

  /// READ ALL — Mengambil semua riwayat transaksi urut terbaru dulu (DESC).
  Future<List<Transaksi>> getAllTransaksi() async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> rows = await db.query(
        tableTransaksi,
        orderBy: 'waktu DESC, id DESC',
      );
      return rows.map((row) => Transaksi.fromMap(row)).toList();
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal membaca daftar transaksi: $e');
    }
  }

  /// READ BY ID — Mengambil satu transaksi berdasarkan ID (null jika tidak ada).
  Future<Transaksi?> getTransaksiById(int id) async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> rows = await db.query(
        tableTransaksi,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Transaksi.fromMap(rows.first);
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal mencari transaksi ID $id: $e');
    }
  }

  /// UPDATE — Memperbarui kolom `status` transaksi berdasarkan ID.
  Future<int> updateStatus(int id, String statusBaru) async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      return await db.update(
        tableTransaksi,
        {'status': statusBaru},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal memperbarui status transaksi ID $id: $e');
    }
  }

  /// DELETE — Menghapus satu transaksi berdasarkan ID.
  Future<int> deleteTransaksi(int id) async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      return await db.delete(
        tableTransaksi,
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal menghapus transaksi ID $id: $e');
    }
  }

  /// DELETE ALL — Menghapus seluruh data riwayat pada tabel `transaksi`.
  Future<int> clearAll() async {
    _cekPlatformDidukung();
    try {
      final Database db = await database;
      return await db.delete(tableTransaksi);
    } on DbWebNotSupportedException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal mengosongkan tabel transaksi: $e');
    }
  }
}
