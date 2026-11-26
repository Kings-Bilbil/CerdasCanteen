import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/canteen_item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodeBayar = 'QRIS Kantin';

  Future<void> _prosesCheckout() async {
    final cart = context.read<CartProvider>();
    final user = context.read<AuthProvider>().currentUser;

    final order = await cart.checkout(
      namaPemesan: user?.nama ?? 'Mahasiswa',
      metodeBayar: _metodeBayar,
    );

    if (!mounted || order == null) return;

    // TODO Integrasi Anggota 2 (SQLite) & Anggota 3 (Notifikasi + QR Struk)
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
        title: const Text('Pesanan Berhasil Dikirim!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode Pesanan : ${order.kodePesanan}'),
            Text('Pemesan      : ${order.namaPemesan}'),
            Text('Metode Bayar : ${order.metodeBayar}'),
            Text('Total Bayar  : ${formatRupiah(order.totalHarga)}'),
            Text('Status       : ${order.status}'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Checkout')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(user?.nama ?? 'Mahasiswa'),
                    subtitle: Text('NIM: ${user?.nim ?? "-"}'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.qty}x ${item.menu.nama}'),
                                ),
                                Text(formatRupiah(item.subtotal)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimasi Siap'),
                            Text('~${cart.estimasiTotalMenit} menit'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Bayar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatRupiah(cart.totalHarga),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'QRIS Kantin',
                      label: Text('QRIS Kantin'),
                      icon: Icon(Icons.qr_code),
                    ),
                    ButtonSegment(
                      value: 'Tunai di Loket',
                      label: Text('Tunai'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: {_metodeBayar},
                  onSelectionChanged: (selected) {
                    setState(() => _metodeBayar = selected.first);
                  },
                ),
                const SizedBox(height: 16),

                // Switch bantu untuk demo Error State (Tugas 8)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simulasi Error Offline / Timeout'),
                  subtitle: const Text(
                    'Aktifkan untuk menguji penanganan error asinkron (Tugas 8)',
                  ),
                  value: cart.simulateNetworkError,
                  onChanged: cart.isCheckingOut
                      ? null
                      : (val) => cart.toggleSimulateNetworkError(val),
                ),
                const SizedBox(height: 12),

                // Error State UI (Tugas 8)
                if (cart.checkoutError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wifi_off, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cart.checkoutError!,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed:
                              cart.isCheckingOut ? null : _prosesCheckout,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),

                // Loading Indicator & Tombol Konfirmasi
                FilledButton(
                  onPressed: (cart.isCheckingOut || cart.isEmpty)
                      ? null
                      : _prosesCheckout,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: cart.isCheckingOut
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Mengirim pesanan ke kantin...'),
                          ],
                        )
                      : Text(
                          'Konfirmasi & Bayar (${formatRupiah(cart.totalHarga)})',
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
