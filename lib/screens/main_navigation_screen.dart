// lib/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../theme/theme_provider.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Counter agar tab Riwayat otomatis memuat ulang data SQLite terbaru setiap dibuka
  int _historyRefreshTick = 0;

  static const _titles = [
    'Menu CerdasCanteen',
    'Keranjang Pesanan',
    'Riwayat Transaksi',
    'Profil Mahasiswa',
  ];

  void _pilihTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _historyRefreshTick++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Tab 0 (Integrasi Anggota 2): HomeScreen dengan API TheMealDB, search & filter
      const HomeScreen(showNavigationActions: false),
      // Tab 1 (Anggota 1): Keranjang pesanan
      const CartScreen(showAppBar: false),
      // Tab 2 (Integrasi Anggota 2): Riwayat transaksi SQLite
      HistoryScreen(
        key: ValueKey('history-$_historyRefreshTick'),
        showAppBar: false,
      ),
      // Tab 3 (Anggota 1 + pintasan Pengaturan Anggota 2): Profil & Logout
      const _ProfileTab(),
    ];

    return Scaffold(
      // Tab 0 (HomeScreen) sudah memiliki AppBar & header pencarian sendiri agar tidak dobel
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              actions: [
                if (_selectedIndex != 1)
                  Selector<CartProvider, int>(
                    selector: (_, cart) => cart.totalItemCount,
                    builder: (context, count, _) {
                      return IconButton(
                        tooltip: 'Buka Keranjang',
                        onPressed: () => _pilihTab(1),
                        icon: Badge(
                          isLabelVisible: count > 0,
                          label: Text('$count'),
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                      );
                    },
                  ),
                IconButton(
                  tooltip: 'Pengaturan',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _pilihTab,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Selector<CartProvider, int>(
              selector: (_, cart) => cart.totalItemCount,
              builder: (context, count, child) => Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Riwayat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Tab 3: Profil & Logout (Anggota 1) + Pintasan Pengaturan & Mode Gelap (Anggota 2)
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.nama ?? 'Mahasiswa',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('NIM: ${user?.nim ?? "-"}'),
                      Text(user?.email ?? '-'),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          AuthService.useDemoMode
                              ? 'Auth Mode: Demo (Siap Switch MySQL)'
                              : 'Auth Mode: MySQL Server Aktif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Pintasan ke SettingsScreen (Mode Gelap, Notifikasi, Nama Panggilan)
              Card(
                child: ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Pengaturan & Mode Gelap',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Tema Gelap aktif • Ketuk untuk atur preferensi'
                        : 'Tema Terang aktif • Ketuk untuk atur preferensi',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.settings),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar (Logout)'),
                onPressed: () {
                  context.read<CartProvider>().clearCart();
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
