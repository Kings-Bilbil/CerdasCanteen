// lib/screens/history_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../models/transaksi.dart';
import '../services/db_helper.dart';
import '../theme/app_theme.dart';

/// Layar Riwayat Transaksi CerdasCanteen — Tugas 10 (SQLite).
/// Menampilkan daftar transaksi dari SQLite (ListView.builder + Card),
/// format Rupiah & tanggal dengan `intl`, swipe-to-delete (Dismissible + konfirmasi),
/// tombol hapus semua, empty/loading state, pull-to-refresh, dan tombol debug sementara.
class HistoryScreen extends StatefulWidget {
  /// Jika false, AppBar disembunyikan (berguna saat dipasang di tab MainNavigationScreen).
  final bool showAppBar;

  const HistoryScreen({
    super.key,
    this.showAppBar = true,
  });

  /// Helper preview khusus Flutter Web agar hasil checkout Anggota 1 ikut muncul
  /// saat uji coba di Web Preview FlutLab (di Android/iOS memakai SQLite nyata).
  static void tambahPreviewWeb(Transaksi transaksi) {
    _HistoryScreenState.simpanPreviewWeb(transaksi);
  }

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DbHelper _dbHelper = DbHelper.instance;

  List<Transaksi> _daftarTransaksi = [];
  bool _sedangMemuat = true;
  String? _pesanInfoWeb;
  String? _pesanError;
  bool _localeSiap = false;

  // Penyimpanan sementara khusus Web Preview FlutLab (tidak persist setelah reload)
  static final List<Transaksi> _webPreviewCache = [];
  static int _webNextId = 1;
  static int _dummyCounter = 0;

  static void simpanPreviewWeb(Transaksi transaksi) {
    _webPreviewCache.insert(0, transaksi.copyWith(id: _webNextId++));
  }

  // Format mata uang Rupiah menggunakan package intl
  final NumberFormat _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _inisialisasiDanMuat();
  }

  /// Memastikan data lokal tanggal `id_ID` siap, lalu memuat riwayat dari SQLite.
  Future<void> _inisialisasiDanMuat() async {
    try {
      await initializeDateFormatting('id_ID', null);
      _localeSiap = true;
    } catch (_) {
      _localeSiap = false;
    }
    await _muatRiwayat();
  }

  /// Memformat DateTime menjadi string tanggal rapi memakai package `intl`.
  String _formatTanggal(DateTime waktu) {
    final DateFormat formatter = _localeSiap
        ? DateFormat('dd MMM yyyy • HH:mm', 'id_ID')
        : DateFormat('dd MMM yyyy • HH:mm');
    return formatter.format(waktu);
  }

  /// Memuat seluruh data transaksi dari SQLite (terbaru dulu).
  Future<void> _muatRiwayat() async {
    setState(() {
      _sedangMemuat = true;
      _pesanError = null;
    });

    try {
      final List<Transaksi> data = await _dbHelper.getAllTransaksi();
      if (!mounted) return;
      setState(() {
        _daftarTransaksi = data;
        _pesanInfoWeb = null;
        _sedangMemuat = false;
      });
    } on DbWebNotSupportedException catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanInfoWeb = e.message;
        _daftarTransaksi = List<Transaksi>.from(_webPreviewCache);
        _sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanError = e.toString();
        _sedangMemuat = false;
      });
    }
  }

  /// Tombol DEBUG sementara: menambah 1 transaksi contoh kantin ke SQLite
  /// supaya HistoryScreen bisa diuji sebelum checkout Anggota 1 terhubung ke DbHelper.
  Future<void> _tambahDataContohDebug() async {
    final List<Map<String, dynamic>> contohPesanan = [
      {
        'ringkasan': '2x Ayam Geprek Sambal, 1x Es Teh Manis',
        'total': 29000.0,
        'status': 'Selesai',
      },
      {
        'ringkasan': '1x Nasi Kuning Telur, 1x Es Jeruk Peras',
        'total': 17000.0,
        'status': 'Diproses',
      },
      {
        'ringkasan': '1x Nasi Uduk Komplit, 1x Bubur Ayam Kampus',
        'total': 20000.0,
        'status': 'Selesai',
      },
      {
        'ringkasan': '1x Mie Goreng Spesial, 2x Risoles Mayo',
        'total': 27000.0,
        'status': 'Diproses',
      },
    ];

    final Map<String, dynamic> pilihan =
        contohPesanan[_dummyCounter % contohPesanan.length];
    _dummyCounter++;

    final DateTime sekarang = DateTime.now();
    final String kode =
        'CC-${DateFormat('yyyyMMdd').format(sekarang)}-${(sekarang.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';

    final Transaksi transaksiBaru = Transaksi(
      kodePesanan: kode,
      ringkasanItem: pilihan['ringkasan'] as String,
      total: pilihan['total'] as double,
      status: pilihan['status'] as String,
      waktu: sekarang,
    );

    try {
      if (kIsWeb) {
        _webPreviewCache.insert(
          0,
          transaksiBaru.copyWith(id: _webNextId++),
        );
      } else {
        await _dbHelper.insertTransaksi(transaksiBaru);
      }
      await _muatRiwayat();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Contoh pesanan $kode ditambahkan (Debug)'),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah data contoh: $e')),
      );
    }
  }

  /// Mengubah status pesanan Diproses <-> Selesai untuk menguji UPDATE SQLite.
  Future<void> _toggleStatusTransaksi(Transaksi trx) async {
    if (trx.id == null) return;
    final String statusBaru = trx.status == 'Selesai' ? 'Diproses' : 'Selesai';

    try {
      if (kIsWeb) {
        final int idx = _webPreviewCache.indexWhere((t) => t.id == trx.id);
        if (idx != -1) {
          _webPreviewCache[idx] = trx.copyWith(status: statusBaru);
        }
      } else {
        await _dbHelper.updateStatus(trx.id!, statusBaru);
      }
      await _muatRiwayat();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e')),
      );
    }
  }

  /// Dialog konfirmasi sebelum menghapus satu transaksi lewat swipe-to-delete.
  Future<bool> _konfirmasiHapusSatu(Transaksi trx) async {
    final bool? setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: Text(
          'Pesanan ${trx.kodePesanan} akan dihapus dari riwayat transaksi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return setuju ?? false;
  }

  /// Menghapus satu transaksi dari SQLite (atau cache sementara jika Web Preview).
  Future<void> _hapusSatuTransaksi(Transaksi trx) async {
    try {
      if (kIsWeb) {
        _webPreviewCache.removeWhere((item) => item.id == trx.id);
      } else if (trx.id != null) {
        await _dbHelper.deleteTransaksi(trx.id!);
      }

      if (!mounted) return;
      setState(() {
        _daftarTransaksi.removeWhere((item) => item.id == trx.id);
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Riwayat ${trx.kodePesanan} berhasil dihapus'),
          ),
        );
    } catch (e) {
      await _muatRiwayat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus riwayat: $e')),
      );
    }
  }

  /// Dialog konfirmasi dan aksi menghapus seluruh riwayat transaksi (clearAll).
  Future<void> _konfirmasiHapusSemua() async {
    if (_daftarTransaksi.isEmpty) return;

    final bool? setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: Text(
          'Seluruh ${_daftarTransaksi.length} riwayat pesanan akan dihapus permanen. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (setuju != true) return;

    try {
      if (kIsWeb) {
        _webPreviewCache.clear();
      } else {
        await _dbHelper.clearAll();
      }
      await _muatRiwayat();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Semua riwayat pesanan berhasil dihapus'),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengosongkan riwayat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Riwayat Pesanan'),
              actions: [
                // Tombol DEBUG sementara untuk tambah data contoh
                IconButton(
                  tooltip: 'Tambah Data Contoh (Debug)',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _tambahDataContohDebug,
                ),
                // Tombol Hapus Semua riwayat
                IconButton(
                  tooltip: 'Hapus Semua Riwayat',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed:
                      _daftarTransaksi.isEmpty ? null : _konfirmasiHapusSemua,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Bar aksi ringkas jika HistoryScreen dipasang tanpa AppBar (di dalam tab)
          if (!widget.showAppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat (${_daftarTransaksi.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _tambahDataContohDebug,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Contoh'),
                      ),
                      if (_daftarTransaksi.isNotEmpty)
                        IconButton(
                          tooltip: 'Hapus Semua',
                          onPressed: _konfirmasiHapusSemua,
                          icon: Icon(
                            Icons.delete_sweep_outlined,
                            color: colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

          // Banner peringatan jelas jika sedang dijalankan di Web Preview FlutLab
          if (_pesanInfoWeb != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_pesanInfoWeb (Preview sementara menggunakan memori browser).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Konten utama: Loading / Error / Empty / ListView.builder + Pull-to-Refresh
          Expanded(
            child: _bangunKonten(theme, colorScheme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _bangunKonten(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // 1. Loading state
    if (_sedangMemuat) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              'Memuat riwayat pesanan...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Error state
    if (_pesanError != null) {
      return RefreshIndicator(
        onRefresh: _muatRiwayat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            Icon(Icons.error_outline_rounded, size: 56, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Gagal Membaca Database',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _pesanError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: _muatRiwayat,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Empty state
    if (_daftarTransaksi.isEmpty) {
      return RefreshIndicator(
        onRefresh: _muatRiwayat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 64),
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada riwayat pesanan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan kantin yang sudah kamu checkout akan tersimpan otomatis di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: FilledButton.icon(
                onPressed: _tambahDataContohDebug,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Contoh Pesanan (Debug)'),
              ),
            ),
          ],
        ),
      );
    }

    // 4. ListView.builder + Card + Dismissible + Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: _muatRiwayat,
      color: colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        // +1 di indeks 0 untuk banner petunjuk swipe-to-delete
        itemCount: _daftarTransaksi.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.swipe_left_rounded,
                    size: 18,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geser kartu ke kiri untuk menghapus • Ketuk status untuk ubah',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final Transaksi trx = _daftarTransaksi[index - 1];
          final bool selesai = trx.status.toLowerCase() == 'selesai';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey('transaksi-${trx.id ?? trx.kodePesanan}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _konfirmasiHapusSatu(trx),
              onDismissed: (_) => _hapusSatuTransaksi(trx),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hapus',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.onError,
                    ),
                  ],
                ),
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: Kode Pesanan + Badge Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              trx.kodePesanan,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _toggleStatusTransaksi(trx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selesai
                                    ? colorScheme.primaryContainer
                                    : colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                trx.status,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: selesai
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Ringkasan item pesanan
                      Text(
                        trx.ringkasanItem,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Divider(height: 1, color: colorScheme.outlineVariant),
                      const SizedBox(height: 10),

                      // Baris bawah: Waktu (intl) + Total Harga (intl)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatTanggal(trx.waktu),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatRupiah.format(trx.total),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.citrusLime
                                  : AppTheme.deepEmerald,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
