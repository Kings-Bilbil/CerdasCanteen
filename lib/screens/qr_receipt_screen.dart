import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../utils/formatters.dart';
import '../utils/queue_estimator.dart';

/// Layar struk digital berisi QR code pesanan.
///
/// QR dipakai kasir/kantin untuk memindai dan memverifikasi pesanan,
/// jadi mahasiswa tidak perlu membawa struk kertas.
class QrReceiptScreen extends StatelessWidget {
  const QrReceiptScreen({
    super.key,
    required this.order,
    this.estimateMinutes,
  });

  final Order order;

  /// Bila null, estimasi dihitung otomatis dari [estimateWaitMinutes].
  final int? estimateMinutes;

  /// Estimasi waktu tunggu dalam menit.
  ///
  /// Bila pesanan kosong (tidak mungkin pada alur normal) fungsi estimator
  /// melempar [ArgumentError], jadi kita tampilkan 0 sebagai fallback agar
  /// layar tidak crash.
  int get resolvedEstimate {
    if (estimateMinutes != null) return estimateMinutes!;
    try {
      return estimateWaitMinutes(
        queueLength: order.queueLength,
        itemCount: order.totalItems,
      );
    } on ArgumentError {
      return 0;
    }
  }

  /// Payload QR: data ringkas yang bisa diverifikasi kantin.
  String get qrData {
    final StringBuffer buffer = StringBuffer()
      ..writeln('CERDASCANTEEN')
      ..writeln('ID:${order.id}')
      ..writeln('ITEM:${order.totalItems}')
      ..writeln('TOTAL:${order.totalPrice}')
      ..writeln('EST:$resolvedEstimate')
      ..write('STATUS:${order.status.label.toUpperCase()}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int estimasi = resolvedEstimate;

    return Scaffold(
      appBar: AppBar(title: const Text('Struk Digital')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: <Widget>[
                  Text('CerdasCanteen', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Struk Pesanan ${order.id}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      semanticsLabel: 'QR kode pesanan ${order.id}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tunjukkan QR ini ke kasir saat mengambil pesanan.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Estimasi waktu tunggu',
                            style: theme.textTheme.bodySmall),
                        Text(
                          formatEstimasiMenit(estimasi),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ...order.items.map(
                  (OrderItem item) => ListTile(
                    dense: true,
                    title: Text(item.name),
                    subtitle: Text('${item.qty} x ${formatRupiah(item.price)}'),
                    trailing: Text(formatRupiah(item.subtotal)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Total'),
                  trailing: Text(
                    formatRupiah(order.totalPrice),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.local_dining_outlined),
                  title: const Text('Status Pesanan'),
                  trailing: Chip(label: Text(order.status.label)),
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Antrean di depan'),
                  trailing: Text('${order.queueLength} orang'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
