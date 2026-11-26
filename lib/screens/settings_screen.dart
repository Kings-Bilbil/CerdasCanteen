// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/prefs_service.dart';
import '../theme/theme_provider.dart';

/// Layar Pengaturan CerdasCanteen — Tugas 10 (SharedPreferences).
/// Menyediakan SwitchListTile Mode Gelap (terhubung real-time ke ThemeProvider),
/// SwitchListTile Notifikasi, input Nama Panggilan dengan validasi Form,
/// tombol Reset Pengaturan dengan dialog konfirmasi, dan info versi aplikasi.
class SettingsScreen extends StatefulWidget {
  /// Jika false, AppBar disembunyikan (berguna saat dipasang di dalam tab navigasi).
  final bool showAppBar;

  const SettingsScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();

  bool _sedangMemuat = true;
  bool _notifikasiAktif = true;
  String _namaTersimpan = 'Mahasiswa';
  String _kategoriTerakhir = 'Semua';

  static const String _versiAplikasi = '1.0.0';

  @override
  void initState() {
    super.initState();
    _muatPreferensi();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  /// Memuat seluruh preferensi tersimpan dari SharedPreferences.
  Future<void> _muatPreferensi() async {
    final String nama = await PrefsService.getNamaPanggilan();
    final bool notif = await PrefsService.getNotifikasiAktif();
    final String kategori = await PrefsService.getKategoriTerakhir();

    if (!mounted) return;
    setState(() {
      _namaTersimpan = nama;
      _namaController.text = nama;
      _notifikasiAktif = notif;
      _kategoriTerakhir = kategori;
      _sedangMemuat = false;
    });
  }

  /// Mengubah status notifikasi pesanan dan menyimpannya ke SharedPreferences.
  Future<void> _ubahNotifikasi(bool nilai) async {
    setState(() {
      _notifikasiAktif = nilai;
    });
    await PrefsService.setNotifikasiAktif(nilai);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            nilai
                ? 'Notifikasi pesanan diaktifkan'
                : 'Notifikasi pesanan dinonaktifkan',
          ),
        ),
      );
  }

  /// Memvalidasi dan menyimpan nama panggilan ke SharedPreferences.
  Future<void> _simpanNamaPanggilan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String namaBaru = _namaController.text.trim();
    await PrefsService.setNamaPanggilan(namaBaru);

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _namaTersimpan = namaBaru;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Nama panggilan "$namaBaru" berhasil disimpan'),
        ),
      );
  }

  /// Menampilkan dialog konfirmasi sebelum mereset seluruh pengaturan ke bawaan.
  Future<void> _konfirmasiResetPengaturan() async {
    final bool? setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan?'),
        content: const Text(
          'Mode gelap, notifikasi pesanan, nama panggilan, dan kategori terakhir '
          'akan dikembalikan ke pengaturan awal.',
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
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    // Reset SharedPreferences dan kembalikan ThemeProvider ke Light Mode seketika
    await PrefsService.resetPengaturan();
    if (!mounted) return;
    await context.read<ThemeProvider>().setDarkMode(false);

    if (!mounted) return;
    setState(() {
      _notifikasiAktif = true;
      _namaTersimpan = 'Mahasiswa';
      _namaController.text = 'Mahasiswa';
      _kategoriTerakhir = 'Semua';
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Semua pengaturan dikembalikan ke bawaan'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    final String inisial = _namaTersimpan.trim().isNotEmpty
        ? _namaTersimpan.trim()[0].toUpperCase()
        : 'M';

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Pengaturan'),
            )
          : null,
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                // 1. Banner sapaan mahasiswa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          inisial,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $_namaTersimpan!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sistem Informasi • UNTAN',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Kartu Preferensi Tampilan & Notifikasi
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // SwitchListTile Mode Gelap -> langsung ubah tema tanpa restart
                      SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            themeProvider.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: const Text(
                          'Mode Gelap',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          themeProvider.isDarkMode
                              ? 'Tema gelap aktif (tersimpan otomatis)'
                              : 'Ubah tampilan terang atau gelap seketika',
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (bool aktif) {
                          context.read<ThemeProvider>().setDarkMode(aktif);
                        },
                      ),

                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),

                      // SwitchListTile Notifikasi Pesanan
                      SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _notifikasiAktif
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_off_outlined,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: const Text(
                          'Notifikasi Pesanan',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'Ingatkan saat pesanan kantin siap diambil',
                        ),
                        value: _notifikasiAktif,
                        onChanged: _ubahNotifikasi,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Kartu Input Nama Panggilan dengan validasi Form
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Panggilan',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dipakai untuk sapaan di aplikasi CerdasCanteen.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _namaController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama panggilan kamu',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (String? value) {
                              final String teks = (value ?? '').trim();
                              if (teks.isEmpty) {
                                return 'Nama panggilan tidak boleh kosong';
                              }
                              if (teks.length < 2) {
                                return 'Nama panggilan minimal 2 karakter';
                              }
                              if (teks.length > 25) {
                                return 'Nama panggilan maksimal 25 karakter';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(teks)) {
                                return 'Gunakan hanya huruf, angka, atau spasi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _simpanNamaPanggilan,
                              icon: const Icon(Icons.save_outlined, size: 19),
                              label: const Text('Simpan Nama Panggilan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Tombol Reset Semua Pengaturan (dengan dialog konfirmasi)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _konfirmasiResetPengaturan,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text(
                      'Reset Semua Pengaturan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Info Versi & Detail Proyek
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text(
                      'CerdasCanteen v$_versiAplikasi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Kelompok 1 • Sistem Informasi UNTAN\n'
                      'Kategori terakhir: $_kategoriTerakhir',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ],
            ),
    );
  }
}
