// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Konfigurasi tema Material 3 (Light & Dark) untuk CerdasCanteen.
/// Palet diambil dari acuan warna Figma kantin segar & ramah mata,
/// dengan font Plus Jakarta Sans dan rasio kontras lolos standar WCAG 2.1 AA.
class AppTheme {
  AppTheme._();

  // Palet warna utama sesuai referensi Figma CerdasCanteen
  static const Color deepEmerald = Color(0xFF007F5F); // Kontras 5.00:1 vs putih (WCAG AA)
  static const Color forestGreen = Color(0xFF2B9348); // Kontras 3.91:1 vs putih (AA Large/UI)
  static const Color leafGreen = Color(0xFF55A630);   // Warna header utama Figma (3.05:1 Large Bold)
  static const Color appleLime = Color(0xFF80B918);   // Aksen terang / Primary Dark (7.50:1 AAA)
  static const Color citrusLime = Color(0xFFAACC00);  // Aksen harga di Dark Mode (8.38:1 AAA)

  // Aksen hangat bertema kantin (untuk bintang rating & sorotan promo)
  static const Color warmAmber = Color(0xFFD97706);
  static const Color warmAmberDarkText = Color(0xFFB45309); // Kontras 5.02:1 vs putih (WCAG AA)

  // Warna permukaan & teks Mode Terang (Light)
  static const Color lightBackground = Color(0xFFF7FAF6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A241E); // Kontras 15.18:1 (AAA)
  static const Color lightTextSecondary = Color(0xFF4B5C51); // Kontras 7.12:1 (AAA)

  // Warna permukaan & teks Mode Gelap (Dark)
  static const Color darkBackground = Color(0xFF111A14);
  static const Color darkCard = Color(0xFF1A271F);
  static const Color darkTextPrimary = Color(0xFFEDF5EE); // Kontras 15.99:1 (AAA)
  static const Color darkTextSecondary = Color(0xFFA9BCB0); // Kontras 7.76:1 (AAA)

  /// Tema Mode Terang (Light Theme)
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: deepEmerald,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD9F3E6),
      onPrimaryContainer: Color(0xFF003828),
      secondary: forestGreen,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE3F5DC),
      onSecondaryContainer: Color(0xFF12381C),
      tertiary: warmAmberDarkText,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFEF3C7),
      onTertiaryContainer: Color(0xFF78350F),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: lightBackground,
      onSurface: lightTextPrimary,
      surfaceContainerLowest: lightCard,
      surfaceContainerLow: Color(0xFFF1F7EF),
      surfaceContainer: Color(0xFFE9F2E7),
      surfaceContainerHigh: Color(0xFFE1ECE0),
      surfaceContainerHighest: Color(0xFFD9E6D7),
      onSurfaceVariant: lightTextSecondary,
      outline: Color(0xFFB5C7B8),
      outlineVariant: Color(0xFFDCE6DD),
    );

    final TextTheme baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: leafGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCard,
        selectedColor: leafGreen,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: deepEmerald,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: const BorderSide(color: leafGreen, width: 1.2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: lightTextSecondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: deepEmerald, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return deepEmerald;
          return colorScheme.outlineVariant;
        }),
      ),
    );
  }

  /// Tema Mode Gelap (Dark Theme)
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: appleLime,
      onPrimary: Color(0xFF0D1B12), // Kontras 7.50:1 (AAA)
      primaryContainer: Color(0xFF1C3B26),
      onPrimaryContainer: Color(0xFFD9F3E6),
      secondary: citrusLime,
      onSecondary: Color(0xFF0D1B12), // Kontras 9.59:1 (AAA)
      secondaryContainer: Color(0xFF283D18),
      onSecondaryContainer: Color(0xFFE7F5C4),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF1F1600),
      tertiaryContainer: Color(0xFF4B3208),
      onTertiaryContainer: Color(0xFFFEF3C7),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: darkBackground,
      onSurface: darkTextPrimary,
      surfaceContainerLowest: Color(0xFF0C130E),
      surfaceContainerLow: Color(0xFF16211A),
      surfaceContainer: darkCard,
      surfaceContainerHigh: Color(0xFF223328),
      surfaceContainerHighest: Color(0xFF2B3F32),
      onSurfaceVariant: darkTextSecondary,
      outline: Color(0xFF475C4E),
      outlineVariant: Color(0xFF2D3E33),
    );

    final TextTheme baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF162A1D),
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: appleLime,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0D1B12),
        ),
        side: const BorderSide(color: Color(0xFF3E5A47), width: 1.2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: darkTextSecondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: appleLime, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appleLime,
          foregroundColor: const Color(0xFF0D1B12),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appleLime,
          foregroundColor: const Color(0xFF0D1B12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0D1B12);
          }
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleLime;
          return colorScheme.outlineVariant;
        }),
      ),
    );
  }
}
