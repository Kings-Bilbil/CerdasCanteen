import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/order.dart';

/// Isi notifikasi yang akan ditampilkan.
///
/// Dipisah dari plugin agar bisa diuji tanpa platform channel (unit test).
class NotificationContent {
  final String title;
  final String body;

  const NotificationContent({required this.title, required this.body});

  @override
  String toString() => '$title | $body';

  @override
  bool operator ==(Object other) =>
      other is NotificationContent &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(title, body);
}

/// Membuat judul & isi notifikasi status pesanan.
///
/// Fungsi murni (pure) sehingga mudah diuji:
/// - [OrderStatus.diproses] -> pesanan mulai dibuat
/// - [OrderStatus.siapDiambil] -> siap diambil + estimasi bila ada
/// - [OrderStatus.selesai] -> pesanan selesai
NotificationContent buildOrderStatusContent(
  OrderStatus status, {
  String? orderId,
  int? estimateMinutes,
}) {
  final String suffix =
      (orderId == null || orderId.isEmpty) ? '' : ' #$orderId';

  switch (status) {
    case OrderStatus.diproses:
      return NotificationContent(
        title: 'Pesanan$suffix Diproses',
        body: 'Pesananmu sedang dibuat oleh kantin. Mohon tunggu sebentar ya.',
      );
    case OrderStatus.siapDiambil:
      final String estimasi = estimateMinutes == null
          ? ''
          : ' Estimasi tunggu ±$estimateMinutes menit.';
      return NotificationContent(
        title: 'Pesanan$suffix Siap Diambil!',
        body: 'Silakan ambil pesananmu di konter kantin sebelum dingin.$estimasi',
      );
    case OrderStatus.selesai:
      return NotificationContent(
        title: 'Pesanan$suffix Selesai',
        body: 'Terima kasih sudah memesan di CerdasCanteen. Selamat makan!',
      );
  }
}

/// Service notifikasi lokal CerdasCanteen.
///
/// Dipakai Anggota 1 pada alur checkout: panggil [showOrderStatus] setiap
/// status pesanan berubah (Diproses -> Siap Diambil).
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _permissionGranted = false;

  bool get isInitialized => _initialized;
  bool get permissionGranted => _permissionGranted;

  static const String channelId = 'cerdascanteen_order_status';
  static const String channelName = 'Status Pesanan';
  static const String channelDescription =
      'Notifikasi perubahan status pesanan CerdasCanteen';

  /// Inisialisasi plugin. Aman dipanggil berulang (idempotent) dan tidak
  /// melempar exception agar aplikasi tidak crash di perangkat tanpa
  /// dukungan notifikasi (mis. web/emulator tanpa Play Service).
  Future<bool> init() async {
    if (_initialized) return true;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false, // diminta manual lewat requestPermission
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      final InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? ok = await _plugin.initialize(settings: settings);
      _initialized = ok ?? true;
      return _initialized;
    } catch (e) {
      debugPrint('NotificationService.init gagal: $e');
      _initialized = false;
      return false;
    }
  }

  /// Minta izin notifikasi (wajib di Android 13+ / API 33+).
  ///
  /// Mengembalikan `false` bila pengguna menolak - aplikasi harus tetap
  /// berjalan, hanya tanpa notifikasi.
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      _permissionGranted = false;
      return false;
    }

    await init();

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? android =
            _plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted = await android?.requestNotificationsPermission();
        _permissionGranted = granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IOSFlutterLocalNotificationsPlugin? ios =
            _plugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        final bool? granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _permissionGranted = granted ?? false;
      } else {
        // Platform lain dianggap tidak butuh izin eksplisit.
        _permissionGranted = true;
      }
    } catch (e) {
      debugPrint('NotificationService.requestPermission gagal: $e');
      _permissionGranted = false;
    }

    return _permissionGranted;
  }

  /// Menampilkan notifikasi status pesanan.
  ///
  /// [estimateMinutes] opsional, hasil dari `estimateWaitMinutes`.
  /// Mengembalikan `true` bila notifikasi berhasil dikirim.
  Future<bool> showOrderStatus(
    OrderStatus status, {
    String? orderId,
    int? estimateMinutes,
    int? notificationId,
  }) async {
    final NotificationContent content = buildOrderStatusContent(
      status,
      orderId: orderId,
      estimateMinutes: estimateMinutes,
    );

    final bool ready = await init();
    if (!ready) {
      debugPrint('Notifikasi dilewati (plugin belum siap): ${content.title}');
      return false;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: notificationId ?? _nextId(),
        title: content.title,
        body: content.body,
        notificationDetails: details,
        payload: status.name,
      );
      return true;
    } catch (e) {
      debugPrint('NotificationService.showOrderStatus gagal: $e');
      return false;
    }
  }

  /// Shortcut untuk menampilkan notifikasi berdasarkan [Order].
  Future<bool> showOrderStatusForOrder(Order order, {int? estimateMinutes}) =>
      showOrderStatus(
        order.status,
        orderId: order.id,
        estimateMinutes: estimateMinutes,
      );

  int _counter = 0;
  int _nextId() => ++_counter;
}
