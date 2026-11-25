// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper SharedPreferences untuk menyimpan preferensi lokal pengguna.
/// Catatan Tahap 2: versi awal untuk kebutuhan ThemeProvider (isDarkMode).
/// Key tambahan (namaPanggilan, notifikasiAktif, kategoriTerakhir, sesi)
/// akan dilengkapi pada Tahap 6.
class PrefsService {
  PrefsService._();

  static const String _keyIsDarkMode = 'is_dark_mode';

  static SharedPreferences? _prefs;

  /// Inisialisasi SharedPreferences satu kali sebelum runApp().
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Memastikan instance SharedPreferences selalu siap dipakai.
  static Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Membaca status mode gelap secara sinkron (jika init() sudah dipanggil).
  static bool getDarkModeSync() {
    return _prefs?.getBool(_keyIsDarkMode) ?? false;
  }

  /// Membaca status mode gelap dari SharedPreferences.
  static Future<bool> getDarkMode() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  /// Menyimpan status mode gelap ke SharedPreferences.
  static Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await _ensurePrefs();
    await prefs.setBool(_keyIsDarkMode, value);
  }
}
