// lib/models/menu_item.dart
import 'canteen_item.dart';

/// Model data untuk satu item menu kantin pada aplikasi CerdasCanteen.
/// Sesuai kontrak bersama Anggota 1 (jangan ubah nama field & method).
class MenuItem {
  final int id;
  final String nama;
  final double harga;
  final String imageUrl;
  final String kategori;
  final String deskripsi;
  final double rating;

  const MenuItem({
    required this.id,
    required this.nama,
    required this.harga,
    required this.imageUrl,
    required this.kategori,
    required this.deskripsi,
    required this.rating,
  });

  /// Menghasilkan harga simulasi deterministik dari ID menu (Rp8.000–Rp35.000, kelipatan 500).
  /// Dipakai saat mengambil data dari TheMealDB yang tidak menyediakan harga.
  static double hitungHargaSimulasi(int id) {
    // Rentang 8.000 sampai 35.000 = 27.000 -> 55 variasi kelipatan 500 (0..54)
    final int langkah = ((id * 37 + 13).abs()) % 55;
    return 8000.0 + (langkah * 500.0);
  }

  /// Menghasilkan rating simulasi deterministik (4.2–5.0) dari ID menu.
  static double hitungRatingSimulasi(int id) {
    final int langkah = ((id * 17).abs()) % 9;
    return double.parse((4.2 + (langkah * 0.1)).toStringAsFixed(1));
  }

  /// Membuat objek MenuItem dari JSON lokal maupun response JSON TheMealDB.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Parse ID dari key aplikasi ('id') atau TheMealDB ('idMeal')
    final int parsedId =
        int.tryParse((json['id'] ?? json['idMeal'] ?? '0').toString()) ?? 0;

    // Parse nama menu
    final String parsedNama =
        (json['nama'] ?? json['strMeal'] ?? 'Menu Kantin').toString().trim();

    // Parse harga; jika tidak ada di JSON (TheMealDB), gunakan harga simulasi deterministik
    final dynamic rawHarga = json['harga'];
    final double parsedHarga = rawHarga != null
        ? (rawHarga is num
            ? rawHarga.toDouble()
            : double.tryParse(rawHarga.toString()) ??
                hitungHargaSimulasi(parsedId))
        : hitungHargaSimulasi(parsedId);

    // Parse URL gambar
    final String parsedImageUrl =
        (json['imageUrl'] ?? json['strMealThumb'] ?? '').toString().trim();

    // Parse kategori menu
    final String parsedKategori =
        (json['kategori'] ?? json['strCategory'] ?? 'Makanan')
            .toString()
            .trim();

    // Parse deskripsi menu; rapikan spasi berlebih jika berasal dari TheMealDB
    final String rawDeskripsi =
        (json['deskripsi'] ?? json['strInstructions'] ?? '').toString().trim();
    final String parsedDeskripsi = rawDeskripsi.isNotEmpty
        ? rawDeskripsi.replaceAll(RegExp(r'\r\n|\r'), '\n')
        : 'Hidangan lezat pilihan kantin kampus CerdasCanteen.';

    // Parse rating; jika tidak ada, gunakan rating simulasi deterministik
    final dynamic rawRating = json['rating'];
    final double parsedRating = rawRating != null
        ? (rawRating is num
            ? rawRating.toDouble()
            : double.tryParse(rawRating.toString()) ??
                hitungRatingSimulasi(parsedId))
        : hitungRatingSimulasi(parsedId);

    return MenuItem(
      id: parsedId,
      nama: parsedNama,
      harga: parsedHarga,
      imageUrl: parsedImageUrl,
      kategori: parsedKategori,
      deskripsi: parsedDeskripsi,
      rating: parsedRating,
    );
  }

  /// Mengubah objek MenuItem menjadi Map (untuk serialisasi / penyimpanan).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'imageUrl': imageUrl,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'rating': rating,
    };
  }

  /// Membuat salinan MenuItem dengan mengubah sebagian field secara immutable.
  MenuItem copyWith({
    int? id,
    String? nama,
    double? harga,
    String? imageUrl,
    String? kategori,
    String? deskripsi,
    double? rating,
  }) {
    return MenuItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      imageUrl: imageUrl ?? this.imageUrl,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      rating: rating ?? this.rating,
    );
  }

  /// Adapter konversi ke model `CanteenMenu` milik Anggota 1 agar langsung
  /// tersambung dengan `CartProvider.addItem(...)` tanpa mengubah file Anggota 1.
  CanteenMenu toCanteenMenu() {
    return CanteenMenu(
      id: id.toString(),
      nama: nama,
      harga: harga.round(),
      kategori: kategori,
      deskripsi: deskripsi,
      gambarUrl: imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuItem(id: $id, nama: $nama, harga: $harga, kategori: $kategori, rating: $rating)';
  }
}
