import 'package:flutter/material.dart';

import 'models/order.dart';
import 'models/order_item.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_receipt_screen.dart';

/// Entry point demo khusus fitur Anggota 3 (native + dokumentasi).
///
/// sengaja dipisah dari `lib/main.dart` (milik Anggota 1) agar tidak bentrok.
/// Jalankan dengan:
/// ```
/// flutter run -t lib/main_anggota3_demo.dart
/// ```
void main() {
  runApp(const Anggota3DemoApp());
}

const Order demoOrder = Order(
  id: 'CC-2024',
  items: <OrderItem>[
    OrderItem(name: 'Nasi Goreng', price: 15000, qty: 2),
    OrderItem(name: 'Es Teh Manis', price: 5000, qty: 1),
  ],
  status: OrderStatus.diproses,
  queueLength: 3,
);

class Anggota3DemoApp extends StatelessWidget {
  const Anggota3DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CerdasCanteen - Demo Anggota 3',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
      ),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatelessWidget {
  const _DemoHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Fitur Native')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Tugas 12 & 14'),
              subtitle: Text(
                'Notifikasi status pesanan, info perangkat, dan struk QR '
                'dengan estimasi antrean.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: const Text('Struk Digital + QR'),
              subtitle: const Text(
                'QR pesanan & estimasi waktu tunggu (queue_estimator)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QrReceiptScreen(order: demoOrder),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil + Info Perangkat'),
              subtitle: const Text(
                'device_info_plus & izin notifikasi Android 13+',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
