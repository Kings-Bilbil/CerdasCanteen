import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/canteen_item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';
import 'menu_detail_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const _titles = [
    'Menu CerdasCanteen',
    'Keranjang Pesanan',
    'Riwayat Transaksi',
    'Profil Mahasiswa',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _MenuTab(),
      CartScreen(showAppBar: false),
      _HistoryTab(),
      _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex != 1)
            Selector<CartProvider, int>(
              selector: (_, cart) => cart.totalItemCount,
              builder: (context, count, _) {
                return IconButton(
                  tooltip: 'Buka Keranjang',
                  onPressed: () => setState(() => _selectedIndex = 1),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                );
              },
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
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Selector<CartProvider, int>(
              selector: (_, cart) => cart.totalItemCount,
              builder: (_, count, __) => Badge(
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

/// Tab 0: Daftar Menu (TODO Integrasi Anggota 2: ganti dengan HomeScreen API)
class _MenuTab extends StatelessWidget {
  const _MenuTab();

  static const List<CanteenMenu> _sampleMenus = [
    CanteenMenu(
      id: 'MK01',
      nama: 'Nasi Ayam Geprek',
      harga: 15000,
      kategori: 'Makanan Berat',
      deskripsi: 'Ayam crispy digeprek sambal bawang hangat + nasi putih.',
      gambarUrl: '',
      estimasiMenit: 6,
    ),
    CanteenMenu(
      id: 'MK02',
      nama: 'Mie Goreng Kantin Spesial',
      harga: 12000,
      kategori: 'Makanan Berat',
      deskripsi: 'Mie goreng telur ceplok, sawi segar, dan kerupuk renyah.',
      gambarUrl: '',
      estimasiMenit: 5,
    ),
    CanteenMenu(
      id: 'MN01',
      nama: 'Es Teh Tarik Kampus',
      harga: 6000,
      kategori: 'Minuman',
      deskripsi: 'Teh tarik dingin manis pas untuk menemani jam istirahat.',
      gambarUrl: '',
      estimasiMenit: 2,
    ),
    CanteenMenu(
      id: 'SN01',
      nama: 'Risoles Mayo (Isi 3)',
      harga: 8000,
      kategori: 'Snack',
      deskripsi: 'Risoles hangat isi smoked beef, telur, dan saus mayones.',
      gambarUrl: '',
      estimasiMenit: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleMenus.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final menu = _sampleMenus[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                menu.kategori == 'Minuman' ? Icons.local_cafe : Icons.fastfood,
                color: colorScheme.primary,
              ),
            ),
            title: Text(
              menu.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${menu.kategori} • ${formatRupiah(menu.harga)} • ~${menu.estimasiMenit} mnt',
            ),
            trailing: IconButton.filledTonal(
              tooltip: 'Tambah cepat ke keranjang',
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                context.read<CartProvider>().addItem(menu);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${menu.nama} ditambahkan ke keranjang'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            // Navigator.push dengan pengantaran data objek menu (Tugas 5)
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => MenuDetailScreen(menu: menu),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Tab 2: Riwayat Pesanan (TODO Integrasi Anggota 2: sambungkan ke SQLite)
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.recentOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada riwayat pesanan'),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cart.recentOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = cart.recentOrders[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long),
                ),
                title: Text(
                  '${order.kodePesanan} • ${formatRupiah(order.totalHarga)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${order.totalItem} item • ${order.metodeBayar}',
                ),
                trailing: Chip(label: Text(order.status)),
              ),
            );
          },
        );
      },
    );
  }
}

/// Tab 3: Profil & Logout (Tugas 11 + TODO Integrasi Anggota 3: Kamera/Notif)
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
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
