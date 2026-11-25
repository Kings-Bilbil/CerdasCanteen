// lib/widgets/menu_card.dart
import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../theme/app_theme.dart';

/// Kartu menu reusable untuk menampilkan satu item kantin di dalam GridView.
/// Memuat widget wajib: Card, Image.network (dengan errorBuilder), Stack (badge),
/// Row, Column, Container, dan tombol tambah ke keranjang.
class MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MenuCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
  });

  /// Helper format angka double menjadi format Rupiah rapi (contoh: Rp18.500).
  static String formatRupiah(double harga) {
    final String angka = harga.round().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < angka.length; i++) {
      final int sisa = angka.length - i;
      buffer.write(angka[i]);
      if (sisa > 1 && sisa % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // [WIDGET WAJIB: Card] Pembungkus utama kartu menu dengan sudut membulat & bayangan
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          // [WIDGET WAJIB: Column] Menyusun gambar, nama menu, dan baris harga secara vertikal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian gambar + badge kategori & rating menggunakan Stack
              Expanded(
                // [WIDGET WAJIB: Stack] Menumpuk badge kategori (kiri atas) & rating (kanan atas) di atas foto
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero animation agar transisi gambar mulus ke DetailScreen (Tahap 4)
                    Hero(
                      tag: 'menu-image-${item.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        // [WIDGET WAJIB: Image] Memuat foto makanan dari URL dengan fallback errorBuilder
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerLow,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.primaryContainer,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_rounded,
                                    size: 32,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Foto tidak tersedia',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Badge kategori di pojok kiri atas
                    Positioned(
                      top: 8,
                      left: 8,
                      // [WIDGET WAJIB: Container] Wadah pill badge kategori
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 92),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.deepEmerald.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.kategori,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Badge rating bintang hangat di pojok kanan atas
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkBackground.withValues(alpha: 0.88)
                              : Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // [WIDGET WAJIB: Row] Menyusun ikon bintang dan angka rating sejajar
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppTheme.warmAmber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Nama menu (maksimal 2 baris agar tinggi kartu konsisten)
              SizedBox(
                height: 36,
                child: Text(
                  item.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Baris bawah: Harga di kiri + tombol Tambah (+) di kanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      formatRupiah(item.harga),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppTheme.citrusLime
                            : AppTheme.deepEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onAddToCart,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.add_rounded,
                          size: 18,
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
    );
  }
}
