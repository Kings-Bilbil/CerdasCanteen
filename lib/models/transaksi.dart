// lib/models/transaksi.dart

/// Model data untuk riwayat transaksi pemesanan kantin CerdasCanteen.
/// Disimpan ke SQLite oleh Anggota 1 saat checkout dan dibaca di HistoryScreen.
class Transaksi {
  final int? id;
  final String kodePesanan;
  final String ringkasanItem;
  final double total;
  final String status;
  final DateTime waktu;

  const Transaksi({
    this.id,
    required this.kodePesanan,
    required this.ringkasanItem,
    required this.total,
    required this.status,
    required this.waktu,
  });

  /// Mengonversi objek Transaksi ke Map sesuai nama kolom tabel SQLite `transaksi`.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'kode_pesanan': kodePesanan,
      'ringkasan_item': ringkasanItem,
      'total': total,
      'status': status,
      'waktu': waktu.toIso8601String(),
    };

    // Hanya sertakan `id` jika tidak null agar AUTOINCREMENT SQLite berjalan otomatis
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  /// Membuat objek Transaksi dari baris data Map hasil query SQLite.
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    final dynamic rawId = map['id'];
    final int? parsedId = rawId is int
        ? rawId
        : (rawId != null ? int.tryParse(rawId.toString()) : null);

    final dynamic rawTotal = map['total'];
    final double parsedTotal = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '0') ?? 0.0;

    return Transaksi(
      id: parsedId,
      kodePesanan:
          (map['kode_pesanan'] ?? map['kodePesanan'] ?? '').toString(),
      ringkasanItem:
          (map['ringkasan_item'] ?? map['ringkasanItem'] ?? '').toString(),
      total: parsedTotal,
      status: (map['status'] ?? 'Diproses').toString(),
      waktu: DateTime.tryParse((map['waktu'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  /// Membuat salinan Transaksi dengan perubahan sebagian field (mis. update status).
  Transaksi copyWith({
    int? id,
    String? kodePesanan,
    String? ringkasanItem,
    double? total,
    String? status,
    DateTime? waktu,
  }) {
    return Transaksi(
      id: id ?? this.id,
      kodePesanan: kodePesanan ?? this.kodePesanan,
      ringkasanItem: ringkasanItem ?? this.ringkasanItem,
      total: total ?? this.total,
      status: status ?? this.status,
      waktu: waktu ?? this.waktu,
    );
  }

  @override
  String toString() {
    return 'Transaksi(id: $id, kodePesanan: $kodePesanan, total: $total, status: $status, waktu: $waktu)';
  }
}
