import '../models/order.dart';

// CATATAN CAKUPAN
// File ini sengaja HANYA berisi bagian murni (pure) dari fitur notifikasi,
// yaitu penyusun judul/isi notifikasi yang bisa diuji unit test tanpa
// platform channel. Kelas yang memanggil plugin (NotificationService)
// adalah implementasi sistem dan dikerjakan pada kode aplikasi.
// Kontrak yang harus dipenuhi implementasi: lihat docs/Variabel.md.

/// Isi notifikasi yang akan ditampilkan.
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
        body:
            'Silakan ambil pesananmu di konter kantin sebelum dingin.$estimasi',
      );
    case OrderStatus.selesai:
      return NotificationContent(
        title: 'Pesanan$suffix Selesai',
        body: 'Terima kasih sudah memesan di CerdasCanteen. Selamat makan!',
      );
  }
}
