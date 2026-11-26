import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  /// Ubah `useDemoMode` menjadi `false` dan arahkan `baseUrl` ke URL server
  /// PHP + MySQL kamu (mis. Ngrok / hosting) saat terhubung ke MySQL asli.
  static const bool useDemoMode = true;
  static const String baseUrl = 'http://localhost/cerdascanteen_api';

  // Penyimpanan akun sementara khusus saat useDemoMode = true
  static final List<Map<String, dynamic>> _demoUsers = [
    {
      'id': 1,
      'nim': 'H1101231001',
      'nama': 'Mahasiswa Demo',
      'email': 'mahasiswa@untan.ac.id',
      'password': '123456',
    },
  ];

  /// Registrasi akun mahasiswa baru (MySQL / Demo)
  Future<UserModel> register({
    required String nim,
    required String nama,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (useDemoMode) {
      await Future.delayed(const Duration(milliseconds: 900));
      final sudahAda = _demoUsers.any((u) => u['email'] == normalizedEmail);
      if (sudahAda) {
        throw const AuthException('Email sudah terdaftar. Silakan login.');
      }

      final newUser = {
        'id': _demoUsers.length + 1,
        'nim': nim.trim().toUpperCase(),
        'nama': nama.trim(),
        'email': normalizedEmail,
        'password': password,
      };
      _demoUsers.add(newUser);
      return UserModel.fromJson({
        ...newUser,
        'token': 'demo_token_${newUser['id']}',
      });
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nim': nim.trim().toUpperCase(),
              'nama': nama.trim(),
              'email': normalizedEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['success'] == true && body['user'] != null) {
          return UserModel.fromJson(body['user'] as Map<String, dynamic>);
        }
      }
      throw AuthException(
        body['message']?.toString() ?? 'Registrasi gagal. Coba lagi.',
      );
    } on TimeoutException {
      throw const AuthException(
        'Koneksi ke server MySQL timeout. Periksa jaringan/server Anda.',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Gagal terhubung ke server autentikasi: $e');
    }
  }

  /// Login akun mahasiswa (MySQL / Demo)
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (useDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      final found = _demoUsers.where(
        (u) => u['email'] == normalizedEmail && u['password'] == password,
      );
      if (found.isEmpty) {
        throw const AuthException('Email atau password salah.');
      }
      final data = found.first;
      return UserModel.fromJson({
        ...data,
        'token': 'demo_token_${data['id']}',
      });
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': normalizedEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['user'] != null) {
        return UserModel.fromJson(body['user'] as Map<String, dynamic>);
      }
      throw AuthException(
        body['message']?.toString() ?? 'Email atau password tidak valid.',
      );
    } on TimeoutException {
      throw const AuthException(
        'Server tidak merespons (timeout). Periksa koneksi internet Anda.',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Terjadi kesalahan jaringan saat login: $e');
    }
  }
}
