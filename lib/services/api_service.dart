// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../models/menu_item.dart';

/// Jenis error jaringan/API agar UI (HomeScreen) bisa menampilkan ikon & pesan berbeda.
enum ApiExceptionType {
  offline,
  timeout,
  serverError,
  invalidFormat,
  unknown,
}

/// Exception khusus untuk kesalahan komunikasi dengan REST API TheMealDB.
class ApiException implements Exception {
  final ApiExceptionType type;
  final String message;

  const ApiException({
    required this.type,
    required this.message,
  });

  @override
  String toString() => 'ApiException($type): $message';
}

/// Layanan HTTP untuk mengambil daftar menu dari TheMealDB (tanpa API key).
/// Dilengkapi async/await, try-catch, timeout 10 detik, dan penanganan error lengkap.
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// Huruf awal pencarian untuk mengumpulkan minimal 10 menu unik dari berbagai kategori.
  /// Huruf 'n' diletakkan pertama agar hidangan nasi (seperti Nasi Lemak) ikut tampil di atas.
  static const List<String> _daftarHuruf = ['n', 'c', 'b', 'a', 's'];

  /// Mengambil minimal 10 menu unik dari TheMealDB API dan mem-parse ke List<MenuItem>.
  /// Harga dibuat deterministik (Rp8.000–Rp35.000, kelipatan 500) di MenuItem.fromJson.
  Future<List<MenuItem>> fetchMenu({
    http.Client? client,
    Duration timeout = _requestTimeout,
  }) async {
    final http.Client httpClient = client ?? http.Client();
    final bool shouldCloseClient = client == null;

    // Gunakan Map berdasar ID agar tidak ada menu duplikat
    final Map<int, MenuItem> menuUnik = {};

    try {
      for (final String huruf in _daftarHuruf) {
        final Uri uri = Uri.parse('$_baseUrl/search.php?f=$huruf');

        // Kirim HTTP GET dengan batas waktu timeout 10 detik
        final http.Response response = await httpClient
            .get(uri)
            .timeout(timeout);

        // Validasi status HTTP harus 200 OK
        if (response.statusCode != 200) {
          throw ApiException(
            type: ApiExceptionType.serverError,
            message:
                'Server mengembalikan status ${response.statusCode}. Silakan coba lagi nanti.',
          );
        }

        // Parse body JSON secara aman
        final dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } on FormatException {
          throw const ApiException(
            type: ApiExceptionType.invalidFormat,
            message: 'Format data JSON dari server rusak atau tidak valid.',
          );
        }

        if (decoded is! Map<String, dynamic>) {
          throw const ApiException(
            type: ApiExceptionType.invalidFormat,
            message: 'Struktur respons API tidak sesuai format JSON yang diharapkan.',
          );
        }

        final dynamic rawMeals = decoded['meals'];
        if (rawMeals == null) {
          // Huruf ini tidak punya hasil di TheMealDB, lanjut ke huruf berikutnya
          continue;
        }

        if (rawMeals is! List) {
          throw const ApiException(
            type: ApiExceptionType.invalidFormat,
            message: 'Field "meals" pada JSON tidak berbentuk daftar (List).',
          );
        }

        for (final dynamic item in rawMeals) {
          if (item is Map<String, dynamic>) {
            final MenuItem menu = MenuItem.fromJson(item);
            if (menu.id != 0) {
              menuUnik[menu.id] = menu;
            }
          }
        }

        // Berhenti lebih awal jika sudah terkumpul minimal 16 menu unik (>= 10)
        // dan minimal 3 kategori agar chip filter tampil variatif
        final int jumlahKategori =
            menuUnik.values.map((m) => m.kategori).toSet().length;
        if (menuUnik.length >= 16 && jumlahKategori >= 3) {
          break;
        }
      }

      if (menuUnik.length < 10) {
        throw const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Data menu dari server kurang dari 10 item.',
        );
      }

      return menuUnik.values.toList();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiExceptionType.timeout,
        message:
            'Waktu koneksi habis (> 10 detik). Jaringan terlalu lambat, silakan coba lagi.',
      );
    } on SocketException {
      // Error offline pada Android / iOS / Desktop
      throw const ApiException(
        type: ApiExceptionType.offline,
        message:
            'Tidak ada koneksi internet. Periksa Wi-Fi atau data seluler kamu lalu coba lagi.',
      );
    } on http.ClientException {
      // Error offline / gagal koneksi pada Flutter Web (FlutLab Preview)
      throw const ApiException(
        type: ApiExceptionType.offline,
        message:
            'Gagal terhubung ke server (offline atau koneksi terputus). Periksa internet kamu.',
      );
    } on FormatException {
      throw const ApiException(
        type: ApiExceptionType.invalidFormat,
        message: 'Terjadi kesalahan saat membaca format data JSON.',
      );
    } catch (e) {
      throw ApiException(
        type: ApiExceptionType.unknown,
        message: 'Terjadi kesalahan tak terduga: $e',
      );
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }
}
