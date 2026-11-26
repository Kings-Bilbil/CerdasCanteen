import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

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

    final String perangkat =
        [manufacturer, model].whereType<String>().where((String s) => s.trim().isNotEmpty).join(' ');
    if (perangkat.isNotEmpty) {
      entries.add(DeviceInfoEntry('Perangkat', perangkat));
    }
    if (_notBlank(brand)) entries.add(DeviceInfoEntry('Merek', brand!));
    if (_notBlank(device)) entries.add(DeviceInfoEntry('Nama internal', device!));
    if (_notBlank(androidVersion)) {
      entries.add(DeviceInfoEntry(
        'Versi Android',
        sdkInt == null ? androidVersion! : 'Android $androidVersion (API $sdkInt)',
      ));
    } else if (sdkInt != null) {
      entries.add(DeviceInfoEntry('API Level', sdkInt.toString()));
    }
    if (_notBlank(iosName)) entries.add(DeviceInfoEntry('Perangkat iOS', iosName!));
    if (_notBlank(iosModel)) entries.add(DeviceInfoEntry('Model iOS', iosModel!));
    if (_notBlank(iosSystemVersion)) {
      entries.add(DeviceInfoEntry('Versi iOS', iosSystemVersion!));
    }
    if (_notBlank(webBrowserName)) {
      entries.add(DeviceInfoEntry('Browser', webBrowserName!));
    }
    if (_notBlank(webPlatform)) entries.add(DeviceInfoEntry('Platform Web', webPlatform!));
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
  static String _shortToken(String token) =>
      token.length <= 16 ? token : '${token.substring(0, 8)}…${token.substring(token.length - 6)}';

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Signature pembaca info perangkat (memudahkan pengujian tanpa plugin).
typedef DeviceSummaryLoader = Future<DeviceSummary> Function();

/// Service informasi perangkat (fitur native: `device_info_plus`).
///
/// Tidak membutuhkan izin runtime apa pun, sehingga aman untuk demo.
class DeviceService {
  DeviceService({DeviceInfoPlugin? plugin, DeviceSummaryLoader? loader})
      : _plugin = plugin ?? DeviceInfoPlugin(),
        _loader = loader;

  static final DeviceService instance = DeviceService();

  final DeviceInfoPlugin _plugin;

  /// Jalur alternatif untuk testing: bila diisi, dipakai menggantikan plugin.
  final DeviceSummaryLoader? _loader;

  DeviceSummary? _cache;

  /// Membaca info perangkat sekali lalu menyimpannya di cache.
  Future<DeviceSummary> load({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    try {
      if (_loader != null) {
        _cache = await _loader();
        return _cache!;
      }
      if (kIsWeb) {
        final WebBrowserInfo web = await _plugin.webBrowserInfo;
        _cache = DeviceSummary.fromRaw(
          webBrowserName: web.browserName.name,
          webPlatform: web.platform,
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo a = await _plugin.androidInfo;
        _cache = DeviceSummary.fromRaw(
          manufacturer: a.manufacturer,
          model: a.model,
          brand: a.brand,
          device: a.device,
          androidVersion: a.version.release,
          sdkInt: a.version.sdkInt,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo i = await _plugin.iosInfo;
        _cache = DeviceSummary.fromRaw(
          iosName: i.name,
          iosModel: i.model,
          iosSystemVersion: i.systemVersion,
        );
      } else {
        _cache = DeviceSummary.fromRaw(
          model: defaultTargetPlatform.name,
        );
      }
    } catch (e) {
      // Fitur info perangkat bersifat "nice to have": jangan sampai
      // menggagalkan halaman profil.
      debugPrint('DeviceService.load gagal: $e');
      _cache = DeviceSummary.fromRaw(model: 'Tidak diketahui');
    }

    return _cache!;
  }

  void clearCache() => _cache = null;
}
