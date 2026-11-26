// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

/// Provider state tema (Light / Dark) dengan persistensi ke SharedPreferences.
/// Didaftarkan pada MultiProvider di main.dart (milik Anggota 1).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Konstruktor otomatis menyinkronkan tema awal jika PrefsService.init()
  /// sudah dipanggil sebelum runApp(), sehingga tidak terjadi kedipan tema.
  ThemeProvider() {
    _themeMode =
        PrefsService.getDarkModeSync() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Mode tema aktif saat ini (ThemeMode.light atau ThemeMode.dark).
  ThemeMode get themeMode => _themeMode;

  /// Helper boolean untuk memeriksa apakah mode gelap sedang aktif.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Memuat preferensi tema tersimpan dari SharedPreferences.
  Future<void> loadTheme() async {
    final bool savedDark = await PrefsService.getDarkMode();
    _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Mengubah tema secara bolak-balik (Light <-> Dark) dan menyimpannya.
  Future<void> toggleTheme() async {
    final bool nextDark = !isDarkMode;
    _themeMode = nextDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await PrefsService.setDarkMode(nextDark);
  }

  /// Mengatur mode gelap secara eksplisit (dipakai oleh SwitchListTile di SettingsScreen).
  Future<void> setDarkMode(bool isDark) async {
    if (isDarkMode == isDark) return;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await PrefsService.setDarkMode(isDark);
  }
}
