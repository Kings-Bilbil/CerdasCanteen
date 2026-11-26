// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  // Pastikan binding Flutter & SharedPreferences siap sebelum UI dirender
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.init();
  runApp(const CerdasCanteenApp());
}

class CerdasCanteenApp extends StatelessWidget {
  const CerdasCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Provider tema Light/Dark dengan persistensi SharedPreferences (Anggota 2)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          // [WIDGET WAJIB: MaterialApp] Root aplikasi dengan tema Material 3 Light & Dark
          return MaterialApp(
            title: 'CerdasCanteen',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: auth.isAuthenticated
                ? const MainNavigationScreen()
                : const LoginScreen(),
            onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
              settings,
              isAuthenticated: auth.isAuthenticated,
            ),
          );
        },
      ),
    );
  }
}
