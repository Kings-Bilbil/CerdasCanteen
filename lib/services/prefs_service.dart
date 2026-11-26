// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper lengkap `SharedPreferences` untuk menyimpan preferensi lokal pengguna
/// dan data sesi (Tugas 10).
/// Key yang dikelola: isDarkMode, namaPanggilan, notifikasiAktif, kategoriTerakhir,
/// serta sesi (token & userId — hanya getter/setter, logika login milik Anggota 1).
class PrefsService {
  PrefsService._();

  // Daftar key penyimpanan lokal SharedPreferences
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyNamaPanggilan = 'nama_panggilan';
  static const String _keyNotifikasiAktif = 'notifikasi_aktif';
  static const String _keyKategoriTerakhir = 'kategori_terakhir';
  static const String _keySessionToken = 'session_token';
  static const String _keySessionUserId = 'session_user_id';

  static SharedPreferences? _prefs;

  /// Inisialisasi SharedPreferences satu kali sebelum runApp() di main.dart.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Memastikan instance SharedPreferences selalu tersedia walau init() belum dipanggil.
  static Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== 1. MODE GELAP (isDarkMode) ====================

  /// Membaca status mode gelap secara sinkron (untuk konstruktor ThemeProvider).
  static bool getDarkModeSync() {
    return _prefs?.getBool(_keyIsDarkMode) ?? false;
  }

  /// Membaca status mode gelap secara asinkron.
  static Future<bool> getDarkMode() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  /// Menyimpan status mode gelap.
  static Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.setBool(_keyIsDarkMode, value);
  }

  // ==================== 2. NAMA PANGGILAN ====================

  /// Membaca nama panggilan mahasiswa (default: "Mahasiswa").
  static Future<String> getNamaPanggilan() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getString(_keyNamaPanggilan) ?? 'Mahasiswa';
  }

  /// Menyimpan nama panggilan mahasiswa.
  static Future<void> setNamaPanggilan(String nama) async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.setString(_keyNamaPanggilan, nama.trim());
  }

  // ==================== 3. NOTIFIKASI AKTIF ====================

  /// Membaca status notifikasi pesanan (default: true).
  static Future<bool> getNotifikasiAktif() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getBool(_keyNotifikasiAktif) ?? true;
  }

  /// Menyimpan status notifikasi pesanan.
  static Future<void> setNotifikasiAktif(bool aktif) async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.setBool(_keyNotifikasiAktif, aktif);
  }

  // ==================== 4. KATEGORI TERAKHIR ====================

  /// Membaca kategori filter menu terakhir yang dipilih pengguna (default: "Semua").
  static Future<String> getKategoriTerakhir() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getString(_keyKategoriTerakhir) ?? 'Semua';
  }

  /// Menyimpan kategori filter menu terakhir yang dipilih pengguna.
  static Future<void> setKategoriTerakhir(String kategori) async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.setString(_keyKategoriTerakhir, kategori);
  }

  // ==================== 5. SESI LOGIN (token & userId) ====================
  // Catatan: hanya menyediakan getter/setter penyimpanan lokal;
  // logika autentikasi sepenuhnya milik Anggota 1 (AuthProvider / AuthService).

  /// Membaca token sesi pengguna (null jika belum login).
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getString(_keySessionToken);
  }

  /// Menyimpan atau menghapus token sesi pengguna.
  static Future<void> setToken(String? token) async {
    final SharedPreferences prefs = await _ensurePrefs();
    if (token == null || token.trim().isEmpty) {
      await prefs.remove(_keySessionToken);
    } else {
      await prefs.setString(_keySessionToken, token.trim());
    }
  }

  /// Membaca userId sesi pengguna (null jika belum login).
  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getString(_keySessionUserId);
  }

  /// Menyimpan atau menghapus userId sesi pengguna.
  static Future<void> setUserId(String? userId) async {
    final SharedPreferences prefs = await _ensurePrefs();
    if (userId == null || userId.trim().isEmpty) {
      await prefs.remove(_keySessionUserId);
    } else {
      await prefs.setString(_keySessionUserId, userId.trim());
    }
  }

  /// Menghapus seluruh data sesi login (dipanggil Anggota 1 saat logout).
  static Future<void> clearSession() async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.remove(_keySessionToken);
    await prefs.remove(_keySessionUserId);
  }

  // ==================== 6. RESET PENGATURAN ====================

  /// Mengembalikan preferensi tampilan & aplikasi ke nilai bawaan
  /// tanpa menghapus sesi login milik Anggota 1.
  static Future<void> resetPengaturan() async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.remove(_keyIsDarkMode);
    await prefs.remove(_keyNamaPanggilan);
    await prefs.remove(_keyNotifikasiAktif);
    await prefs.remove(_keyKategoriTerakhir);
  }
}
