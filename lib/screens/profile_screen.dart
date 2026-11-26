import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/device_service.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';

/// Halaman Profil mahasiswa CerdasCanteen.
///
/// Menampilkan fitur native `device_info_plus` (info perangkat) dan tombol
/// untuk mencoba notifikasi status pesanan (`NotificationService`).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.studentName = 'Mahasiswa CerdasCanteen',
    this.studentId = '2210512000',
    this.deviceService,
    this.notificationService,
  });

  final String studentName;
  final String studentId;

  /// Dapat diganti saat testing (dependency injection).
  final DeviceService? deviceService;
  final NotificationService? notificationService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final DeviceService _deviceService =
      widget.deviceService ?? DeviceService.instance;
  late final NotificationService _notificationService =
      widget.notificationService ?? NotificationService.instance;

  late Future<DeviceSummary> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.load();
  }

  Future<void> _refreshDevice() async {
    setState(() {
      _deviceFuture = _deviceService.load(forceRefresh: true);
    });
    await _deviceFuture;
  }

  Future<void> _cobaNotifikasi() async {
    final bool granted = _notificationService.permissionGranted ||
        await _notificationService.requestPermission();

    if (!mounted) return;

    if (!granted) {
      // Kasus izin ditolak: tetap beri tahu pengguna, jangan crash.
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Izin notifikasi ditolak'),
          content: const Text(
            'CerdasCanteen tidak bisa mengirim kabar "Siap Diambil". '
            'Aktifkan izin notifikasi di pengaturan perangkat bila ingin '
            'menerima update status pesanan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    final bool sent = await _notificationService.showOrderStatus(
      OrderStatus.siapDiambil,
      orderId: 'CC-001',
      estimateMinutes: 9,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Notifikasi "Siap Diambil" dikirim.'
              : 'Notifikasi tidak dapat dikirim di perangkat ini.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang info perangkat',
            onPressed: _refreshDevice,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _HeaderCard(name: widget.studentName, studentId: widget.studentId),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Informasi Perangkat', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Dibaca langsung dari perangkat (plugin device_info_plus)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  FutureBuilder<DeviceSummary>(
                    future: _deviceFuture,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<DeviceSummary> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Gagal membaca info perangkat: '
                            '${snapshot.error}');
                      }
                      final List<DeviceInfoEntry> entries =
                          snapshot.data?.displayed ?? <DeviceInfoEntry>[];
                      if (entries.isEmpty) {
                        return const Text('Info perangkat tidak tersedia.');
                      }
                      return Column(
                        children: entries
                            .map((DeviceInfoEntry e) => _InfoRow(
                                  label: e.label,
                                  value: e.value,
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Notifikasi Pesanan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Minta izin notifikasi Android 13+ lalu kirim contoh '
                    'notifikasi status "Siap Diambil".',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _cobaNotifikasi,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Coba Notifikasi "Siap Diambil"'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total belanja contoh: ${formatRupiah(48500)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.name, required this.studentId});

  final String name;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('NIM $studentId',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
