import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
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
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'CerdasCanteen',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE65100),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
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
