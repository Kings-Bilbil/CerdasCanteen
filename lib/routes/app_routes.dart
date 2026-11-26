// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

import '../models/canteen_item.dart';
import '../models/menu_item.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/history_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/menu_detail_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String detail = '/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(
    RouteSettings routeSettings, {
    required bool isAuthenticated,
  }) {
    final routeName = routeSettings.name;

    // Proteksi halaman (Tugas 11): redirect ke Login jika belum autentikasi
    final isPublicRoute = routeName == login || routeName == register;
    if (!isAuthenticated && !isPublicRoute) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: login),
        builder: (_) => const LoginScreen(),
      );
    }

    switch (routeName) {
      case login:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => isAuthenticated
              ? const MainNavigationScreen()
              : const LoginScreen(),
        );
      case register:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const RegisterScreen(),
        );
      case main:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const MainNavigationScreen(),
        );
      case detail:
        final menu = routeSettings.arguments;
        // Dukung MenuItem (HomeScreen API Anggota 2 -> DetailScreen)
        if (menu is MenuItem) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (_) => const DetailScreen(),
          );
        }
        // Pertahankan kompatibilitas CanteenMenu milik Anggota 1
        if (menu is CanteenMenu) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (_) => MenuDetailScreen(menu: menu),
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const MainNavigationScreen(),
        );
      case cart:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const CartScreen(),
        );
      case checkout:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const CheckoutScreen(),
        );
      case history:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const HistoryScreen(),
        );
      case settings:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => isAuthenticated
              ? const MainNavigationScreen()
              : const LoginScreen(),
        );
    }
  }
}
