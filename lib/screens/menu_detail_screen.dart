import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/canteen_item.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class MenuDetailScreen extends StatefulWidget {
  final CanteenMenu menu;

  const MenuDetailScreen({super.key, required this.menu});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  // State lokal menggunakan setState (Tugas 6)
  int _qty = 1;
  bool _isFavorite = false;
  bool _takeAway = false;
  bool _ekstraPedas = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  int get _subtotalLokal {
    final biayaBungkus = _takeAway ? 1000 : 0;
    return (widget.menu.harga + biayaBungkus) * _qty;
  }

  void _tambahKeKeranjang() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CartProvider>().addItem(
          widget.menu,
          qty: _qty,
          catatan: _catatanController.text,
          takeAway: _takeAway,
          ekstraPedas: _ekstraPedas,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.menu.nama} (x$_qty) masuk keranjang!'),
        action: SnackBarAction(
          label: 'Lihat Keranjang',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu.nama),
        actions: [
          // Tombol Like / Favorit (setState)
          IconButton(
            tooltip: 'Favoritkan menu',
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          // Badge sinkron dari CartProvider (Selector)
          Selector<CartProvider, int>(
            selector: (_, cart) => cart.totalItemCount,
            builder: (context, count, _) {
              return IconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header visual menu
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.menu.kategori == 'Minuman'
                          ? Icons.local_cafe_rounded
                          : Icons.lunch_dining_rounded,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Chip(label: Text(widget.menu.kategori)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.menu.nama,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    formatRupiah(widget.menu.harga),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.menu.deskripsi),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                      'Estimasi penyajian: ~${widget.menu.estimasiMenit} menit'),
                ],
              ),
              const Divider(height: 32),

              // Switch lokal menggunakan setState
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bungkus / Take-Away'),
                subtitle: const Text('Tambahan kemasan +Rp1.000 per porsi'),
                value: _takeAway,
                onChanged: (val) => setState(() => _takeAway = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ekstra Pedas / Sambal Pisah'),
                subtitle: const Text('Gratis sesuai selera'),
                value: _ekstraPedas,
                onChanged: (val) => setState(() => _ekstraPedas = val),
              ),
              const SizedBox(height: 12),

              // Form validasi catatan lokal
              TextFormField(
                controller: _catatanController,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Catatan untuk penjual (opsional)',
                  hintText: 'Contoh: tanpa daun bawang / es sedikit',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.length > 60) {
                    return 'Catatan maksimal 60 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Counter / Badge jumlah item lokal (setState)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed:
                            _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_qty',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: () => setState(() => _qty++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _tambahKeKeranjang,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    'Tambah ke Keranjang • ${formatRupiah(_subtotalLokal)}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
