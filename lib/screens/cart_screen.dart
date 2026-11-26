import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/canteen_item.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  final bool showAppBar;

  const CartScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Keranjang pesanan masih kosong',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih menu kantin favoritmu terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  final tags = <String>[
                    if (item.takeAway) 'Take-Away (+Rp1.000)',
                    if (item.ekstraPedas) 'Ekstra Pedas',
                    if (item.catatan.isNotEmpty) 'Catatan: ${item.catatan}',
                  ];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menu.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatRupiah(item.hargaSatuanFinal)} x ${item.qty} = ${formatRupiah(item.subtotal)}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (tags.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    tags.join(' • '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cart.decrementQty(index),
                              ),
                              Text(
                                '${item.qty}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => cart.incrementQty(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => cart.removeItem(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Footer menggunakan Selector agar hanya rebuild saat totalHarga berubah
        Selector<CartProvider, int>(
          selector: (_, cart) => cart.totalHarga,
          builder: (context, totalHarga, _) {
            if (totalHarga == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Pembayaran'),
                        Text(
                          formatRupiah(totalHarga),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.checkout);
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );

    if (!showAppBar) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Pesanan')),
      body: content,
    );
  }
}
