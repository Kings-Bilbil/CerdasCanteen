// CATATAN CAKUPAN
// File ini sengaja HANYA berisi bagian murni (pure) dari fitur info
// perangkat, yaitu penyusun ringkasan yang bisa diuji unit test tanpa plugin
// native. Pemanggilan plugin dan halaman profil adalah implementasi sistem.
// Kontrak yang harus dipenuhi implementasi: lihat docs/Variabel.md.

/// Satu baris informasi perangkat yang ditampilkan pada layar Profil.
class DeviceInfoEntry {
  final String label;
  final String value;

  const DeviceInfoEntry(this.label, this.value);

  @override
  String toString() => '$label: $value';

  @override
  bool operator ==(Object other) =>
      other is DeviceInfoEntry && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// Ringkasan perangkat untuk halaman profil CerdasCanteen.
///
/// Dibuat sebagai kelas nilai supaya bisa diuji unit test tanpa plugin.
class DeviceSummary {
  final List<DeviceInfoEntry> entries;

  const DeviceSummary(this.entries);

  bool get isEmpty => entries.isEmpty;

  List<DeviceInfoEntry> get displayed =>
      entries.where((DeviceInfoEntry e) => e.value.trim().isNotEmpty).toList();

  /// Membuat ringkasan dari data mentah perangkat.
  ///
  /// Semua parameter nullable: bila data tidak tersedia, entri dilewati.
  /// Ini meniru kasus riil ketika plugin gagal membaca sebagian data.
  factory DeviceSummary.fromRaw({
    String? manufacturer,
    String? model,
    String? brand,
    String? device,
    String? androidVersion,
    int? sdkInt,
    String? iosName,
    String? iosSystemVersion,
    String? iosModel,
    String? webBrowserName,
    String? webPlatform,
    String? fcmToken,
    DateTime? now,
  }) {
    final List<DeviceInfoEntry> entries = <DeviceInfoEntry>[];

    final String perangkat = [manufacturer, model]
        .whereType<String>()
        .where((String s) => s.trim().isNotEmpty)
        .join(' ');
    if (perangkat.isNotEmpty) {
      entries.add(DeviceInfoEntry('Perangkat', perangkat));
    }
    if (_notBlank(brand)) entries.add(DeviceInfoEntry('Merek', brand!));
    if (_notBlank(device)) {
      entries.add(DeviceInfoEntry('Nama internal', device!));
    }
    if (_notBlank(androidVersion)) {
      entries.add(DeviceInfoEntry(
        'Versi Android',
        sdkInt == null ? androidVersion! : 'Android $androidVersion (API $sdkInt)',
      ));
    } else if (sdkInt != null) {
      entries.add(DeviceInfoEntry('API Level', sdkInt.toString()));
    }
    if (_notBlank(iosName)) {
      entries.add(DeviceInfoEntry('Perangkat iOS', iosName!));
    }
    if (_notBlank(iosModel)) {
      entries.add(DeviceInfoEntry('Model iOS', iosModel!));
    }
    if (_notBlank(iosSystemVersion)) {
      entries.add(DeviceInfoEntry('Versi iOS', iosSystemVersion!));
    }
    if (_notBlank(webBrowserName)) {
      entries.add(DeviceInfoEntry('Browser', webBrowserName!));
    }
    if (_notBlank(webPlatform)) {
      entries.add(DeviceInfoEntry('Platform Web', webPlatform!));
    }
    if (_notBlank(fcmToken)) {
      entries.add(DeviceInfoEntry('Token notifikasi', _shortToken(fcmToken!)));
    }
    entries.add(DeviceInfoEntry(
      'Login terakhir',
      _formatDate(now ?? DateTime.now()),
    ));

    return DeviceSummary(entries);
  }

  static bool _notBlank(String? v) => v != null && v.trim().isNotEmpty;

  /// Token panjang dipotong agar rapi di layar.
  static String _shortToken(String token) => token.length <= 16
      ? token
      : '${token.substring(0, 8)}…${token.substring(token.length - 6)}';

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}
