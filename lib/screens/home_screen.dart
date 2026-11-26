// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/menu_card.dart';

/// Layar Utama (Daftar Menu Kantin) CerdasCanteen — Tugas 3, 4, 8 UI, dan 9.
///
/// CATATAN WIDGET WAJIB:
/// - [WIDGET WAJIB: MaterialApp] -> dipasang di root aplikasi pada `lib/main.dart`
///   (milik Anggota 1) yang membungkus seluruh routes termasuk `HomeScreen`.
/// - [WIDGET WAJIB: Scaffold, AppBar, Column, Row, Stack, Container, TextField] ->
///   ditandai langsung pada baris di bawah ini.
/// - [WIDGET WAJIB: Card, Image] -> dipakai di dalam `MenuCard` (`lib/widgets/menu_card.dart`).
class HomeScreen extends StatefulWidget {
  /// Jika true (default), ikon pintasan Riwayat & Pengaturan ditampilkan di AppBar.
  /// Anggota 1 dapat mengisi false jika HomeScreen dibungkus BottomNavigationBar.
  final bool showNavigationActions;

  const HomeScreen({
    super.key,
    this.showNavigationActions = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<MenuItem> _semuaMenu = [];
  bool _sedangMemuat = true;
  ApiException? _errorApi;

  String _kataKunci = '';
  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _muatMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mengambil daftar menu dari TheMealDB API dengan manajemen state loading & error.
  Future<void> _muatMenu() async {
    setState(() {
      _sedangMemuat = true;
      _errorApi = null;
    });

    try {
      final List<MenuItem> hasil = await _apiService.fetchMenu();
      if (!mounted) return;
      setState(() {
        _semuaMenu = hasil;
        _sedangMemuat = false;
        // Jika kategori terpilih sebelumnya tidak ada di data baru, reset ke 'Semua'
        if (_kategoriTerpilih != 'Semua' &&
            !_daftarKategoriDinamis.contains(_kategoriTerpilih)) {
          _kategoriTerpilih = 'Semua';
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorApi = e;
        _sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorApi = ApiException(
          type: ApiExceptionType.unknown,
          message: 'Gagal memuat menu: $e',
        );
        _sedangMemuat = false;
      });
    }
  }

  /// Menghasilkan daftar kategori secara DINAMIS dari data API (tidak di-hardcode),
  /// selalu diawali chip "Semua".
  List<String> get _daftarKategoriDinamis {
    final List<String> kategoriUnik =
        _semuaMenu.map((item) => item.kategori).toSet().toList()..sort();
    return ['Semua', ...kategoriUnik];
  }

  /// Menggabungkan filter kategori dan pencarian kata kunci secara real-time.
  List<MenuItem> get _menuTersaring {
    final String query = _kataKunci.trim().toLowerCase();
    return _semuaMenu.where((MenuItem item) {
      final bool cocokKategori = _kategoriTerpilih == 'Semua' ||
          item.kategori.toLowerCase() == _kategoriTerpilih.toLowerCase();
      final bool cocokPencarian = query.isEmpty ||
          item.nama.toLowerCase().contains(query) ||
          item.kategori.toLowerCase().contains(query);
      return cocokKategori && cocokPencarian;
    }).toList();
  }

  /// Menambahkan item ke CartProvider (kontrak Anggota 1) dan menampilkan SnackBar.
  void _tambahKeKeranjang(MenuItem item) {
    // Konversi MenuItem ke CanteenMenu agar langsung klop dengan CartProvider Anggota 1
    context.read<CartProvider>().addItem(item.toCanteenMenu());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text('${item.nama} ditambahkan ke keranjang'),
          action: SnackBarAction(
            label: 'Lihat',
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
    final Color warnaHeader =
        isDark ? const Color(0xFF162A1D) : AppTheme.leafGreen;

    // Pantau total jumlah item di keranjang untuk badge ikon Cart
    final int jumlahKeranjang = context.watch<CartProvider>().totalItemCount;

    // [WIDGET WAJIB: Scaffold] Kerangka dasar layar HomeScreen
    return Scaffold(
      // [WIDGET WAJIB: AppBar] Bilah judul atas dengan aksi Riwayat, Pengaturan, dan Keranjang
      appBar: AppBar(
        backgroundColor: warnaHeader,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CerdasCanteen'),
            Text(
              'Pesan cepat tanpa antre kantin',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.showNavigationActions) ...[
            IconButton(
              tooltip: 'Riwayat Pesanan',
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.pushNamed(context, '/history'),
            ),
            IconButton(
              tooltip: 'Pengaturan',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
          // [WIDGET WAJIB: Stack] Menumpuk badge angka jumlah item di atas ikon keranjang
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Keranjang Belanja',
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: isDark ? AppTheme.citrusLime : Colors.white,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
                if (jumlahKeranjang > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warmAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        jumlahKeranjang > 99 ? '99+' : '$jumlahKeranjang',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // [WIDGET WAJIB: Column] Menyusun header pencarian, chip filter, dan area daftar menu
      body: Column(
        children: [
          // [WIDGET WAJIB: Container] Header hijau melengkung berisi kolom pencarian pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            decoration: BoxDecoration(
              color: warnaHeader,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            // [WIDGET WAJIB: TextField] Pencarian menu secara real-time
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (String value) {
                setState(() {
                  _kataKunci = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari makanan atau kategori favoritmu...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppTheme.appleLime : AppTheme.leafGreen,
                ),
                suffixIcon: _kataKunci.isNotEmpty
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _kataKunci = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Area konten utama (Loading / Error / Filter + GridView dengan Pull-to-Refresh)
          Expanded(
            child: _bangunKontenUtama(theme, colorScheme, isDark),
          ),
        ],
      ),
    );
  }

  /// Memilih tampilan konten berdasarkan state: Loading, Error, atau Daftar Menu.
  Widget _bangunKontenUtama(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // 1. State Loading
    if (_sedangMemuat) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Memuat daftar menu kantin...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // 2. State Error (membedakan ikon & pesan untuk offline vs timeout vs lainnya)
    if (_errorApi != null) {
      return RefreshIndicator(
        onRefresh: _muatMenu,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            _bangunKartuError(theme, colorScheme, _errorApi!),
          ],
        ),
      );
    }

    // 3. State Data Berhasil Dimuat: Chip Filter Dinamis + Grid Responsif
    final List<String> kategori = _daftarKategoriDinamis;
    final List<MenuItem> menuAktif = _menuTersaring;

    return RefreshIndicator(
      onRefresh: _muatMenu,
      color: colorScheme.primary,
      child: Column(
        children: [
          // Baris ChoiceChip filter kategori horizontal (diambil otomatis dari data API)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: kategori.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final String namaKategori = kategori[index];
                final bool terpilih = _kategoriTerpilih == namaKategori;
                return ChoiceChip(
                  label: Text(namaKategori),
                  selected: terpilih,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() {
                      _kategoriTerpilih = namaKategori;
                    });
                  },
                );
              },
            ),
          ),

          // [WIDGET WAJIB: Row] Info jumlah menu dan filter aktif
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Menu (${menuAktif.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Filter: $_kategoriTerpilih',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppTheme.citrusLime : AppTheme.deepEmerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Daftar GridView responsif atau pesan "Menu tidak ditemukan"
          Expanded(
            child: menuAktif.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(28),
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Menu tidak ditemukan',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tidak ada menu yang cocok dengan kata kunci "$_kataKunci" pada kategori "$_kategoriTerpilih".',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reset Pencarian & Filter'),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _kataKunci = '';
                              _kategoriTerpilih = 'Semua';
                            });
                          },
                        ),
                      ),
                    ],
                  )
                // LayoutBuilder menentukan jumlah kolom responsif secara otomatis
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final double lebar = constraints.maxWidth;
                      // Responsif: 2 kolom (HP sempit), 3 kolom (tablet), 4 kolom (layar lebar)
                      final int jumlahKolom = lebar >= 900
                          ? 4
                          : lebar >= 600
                              ? 3
                              : 2;

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: jumlahKolom,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          // Tinggi tetap agar kartu tidak pernah overflow di berbagai lebar layar
                          mainAxisExtent: 256,
                        ),
                        itemCount: menuAktif.length,
                        itemBuilder: (context, index) {
                          final MenuItem item = menuAktif[index];
                          return MenuCard(
                            item: item,
                            // Navigasi ke DetailScreen sesuai kontrak Anggota 1
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: item,
                            ),
                            onAddToCart: () => _tambahKeKeranjang(item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Kartu status error dengan ikon dan judul berbeda antara offline, timeout, dan error lain.
  Widget _bangunKartuError(
    ThemeData theme,
    ColorScheme colorScheme,
    ApiException error,
  ) {
    final IconData ikon;
    final String judul;

    switch (error.type) {
      case ApiExceptionType.offline:
        ikon = Icons.wifi_off_rounded;
        judul = 'Kamu Sedang Offline';
        break;
      case ApiExceptionType.timeout:
        ikon = Icons.timer_off_rounded;
        judul = 'Koneksi Waktu Habis';
        break;
      case ApiExceptionType.serverError:
        ikon = Icons.cloud_off_rounded;
        judul = 'Gangguan Server Menu';
        break;
      case ApiExceptionType.invalidFormat:
        ikon = Icons.broken_image_outlined;
        judul = 'Data Menu Rusak';
        break;
      case ApiExceptionType.unknown:
        ikon = Icons.error_outline_rounded;
        judul = 'Gagal Memuat Menu';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 60, color: colorScheme.error),
            const SizedBox(height: 14),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _muatMenu,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
