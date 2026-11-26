import 'package:flutter/material.dart';
import '../models/canteen_item.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/menu_detail_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String detail = '/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required bool isAuthenticated,
  }) {
    final routeName = settings.name;

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
          settings: settings,
          builder: (_) => isAuthenticated
              ? const MainNavigationScreen()
              : const LoginScreen(),
        );
      case register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case main:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationScreen(),
        );
      case detail:
        final menu = settings.arguments;
        if (menu is CanteenMenu) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => MenuDetailScreen(menu: menu),
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const MainNavigationScreen(),
        );
      case cart:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartScreen(),
        );
      case checkout:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CheckoutScreen(),
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
