// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/canteen_item.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/menu_card.dart';

/// Layar Detail Menu CerdasCanteen — Tugas 4 & 6.
/// Menerima MenuItem lewat ModalRoute arguments, menampilkan Hero image,
/// info lengkap menu, tombol favorit (setState), counter jumlah minimal 1 (setState),
/// dan tombol Tambah ke Keranjang yang memanggil CartProvider.addItem() sebanyak jumlah.
class DetailScreen extends StatefulWidget {
  /// Opsional jika dipanggil langsung lewat konstruktor; prioritas utama tetap ModalRoute arguments.
  final MenuItem? menu;

  const DetailScreen({
    super.key,
    this.menu,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // State lokal counter jumlah pesanan (minimal 1)
  int _jumlah = 1;

  // State lokal tombol favorit di AppBar
  bool _isFavorit = false;

  /// Mengambil objek MenuItem dari ModalRoute arguments (atau fallback parameter konstruktor).
  MenuItem? _ambilMenuItem(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is MenuItem) {
      return args;
    }

    // Fallback aman jika ada navigasi yang mengirim CanteenMenu milik Anggota 1
    if (args is CanteenMenu) {
      final int parsedId = int.tryParse(args.id) ?? args.id.hashCode.abs();
      return MenuItem(
        id: parsedId,
        nama: args.nama,
        harga: args.harga.toDouble(),
        imageUrl: args.gambarUrl,
        kategori: args.kategori,
        deskripsi: args.deskripsi,
        rating: MenuItem.hitungRatingSimulasi(parsedId),
      );
    }

    return widget.menu;
  }

  /// Mengurangi jumlah pesanan (dijaga minimal 1).
  void _kurangiJumlah() {
    if (_jumlah <= 1) return;
    setState(() {
      _jumlah--;
    });
  }

  /// Menambah jumlah pesanan.
  void _tambahJumlah() {
    setState(() {
      _jumlah++;
    });
  }

  /// Toggle status favorit di AppBar dengan umpan balik SnackBar.
  void _toggleFavorit(MenuItem item) {
    setState(() {
      _isFavorit = !_isFavorit;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            _isFavorit
                ? '${item.nama} ditambahkan ke menu favorit'
                : '${item.nama} dihapus dari menu favorit',
          ),
        ),
      );
  }

  /// Menambahkan menu ke CartProvider sebanyak `_jumlah` sesuai kontrak Tugas 4 & 6.
  void _tambahKeKeranjang(MenuItem item) {
    final CartProvider cartProvider = context.read<CartProvider>();
    final CanteenMenu canteenMenu = item.toCanteenMenu();

    // Panggil addItem() sebanyak jumlah yang dipilih pengguna
    for (int i = 0; i < _jumlah; i++) {
      cartProvider.addItem(canteenMenu);
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text('$_jumlah x ${item.nama} masuk ke keranjang'),
          action: SnackBarAction(
            label: 'Keranjang',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final MenuItem? item = _ambilMenuItem(context);

    // Tampilan aman jika halaman dibuka tanpa membawa argumen MenuItem
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Menu')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Data menu tidak ditemukan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Kembali ke Daftar Menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double totalHarga = item.harga * _jumlah;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Menu'),
        actions: [
          // Tombol favorit di AppBar yang mengubah state lewat setState()
          IconButton(
            tooltip: _isFavorit ? 'Hapus dari favorit' : 'Tandai favorit',
            onPressed: () => _toggleFavorit(item),
            icon: Icon(
              _isFavorit
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorit
                  ? const Color(0xFFFF5252)
                  : (isDark ? AppTheme.darkTextPrimary : Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Buka Keranjang',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar besar menu dengan Hero animation dari MenuCard
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Hero(
                tag: 'menu-image-${item.id}',
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerLow,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.leafGreen, AppTheme.deepEmerald],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 72,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Konten detail menu
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris badge kategori dan badge rating hangat
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.kategori,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppTheme.warmAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.rating.toStringAsFixed(1)}  •  Kantin Kampus',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Nama menu
                  Text(
                    item.nama,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Harga satuan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        MenuCard.formatRupiah(item.harga),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppTheme.citrusLime
                              : AppTheme.deepEmerald,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ porsi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Kartu counter jumlah pesanan (setState, minimal 1)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah Pesanan',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Minimal 1 porsi',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Tombol kurang (-) nonaktif saat _jumlah == 1
                              Material(
                                color: _jumlah > 1
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _jumlah > 1 ? _kurangiJumlah : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 20,
                                      color: _jumlah > 1
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 42,
                                child: Text(
                                  '$_jumlah',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              // Tombol tambah (+)
                              Material(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _tambahJumlah,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Bagian Deskripsi Menu
                  Text(
                    'Deskripsi Menu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.deskripsi,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Tombol sticky bawah: Tambah ke Keranjang + total harga
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _tambahKeKeranjang(item),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                'Tambah ke Keranjang  •  ${MenuCard.formatRupiah(totalHarga)}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
