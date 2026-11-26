import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/canteen_item.dart';
import '../models/transaksi.dart';
import '../screens/history_screen.dart';
import '../services/db_helper.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final List<OrderRecord> _recentOrders = [];

  bool _isCheckingOut = false;
  String? _checkoutError;
  bool _simulateNetworkError = false;

  List<CartItem> get items => List.unmodifiable(_items);
  List<OrderRecord> get recentOrders => List.unmodifiable(_recentOrders);
  bool get isEmpty => _items.isEmpty;
  bool get isCheckingOut => _isCheckingOut;
  String? get checkoutError => _checkoutError;
  bool get simulateNetworkError => _simulateNetworkError;

  int get totalItemCount => _items.fold(0, (total, item) => total + item.qty);

  int get totalHarga => _items.fold(0, (total, item) => total + item.subtotal);

  int get estimasiTotalMenit {
    if (_items.isEmpty) return 0;
    final estimasiMaks =
        _items.map((e) => e.menu.estimasiMenit).reduce((a, b) => a > b ? a : b);
    return estimasiMaks + ((totalItemCount - 1) * 2);
  }

  void toggleSimulateNetworkError(bool value) {
    _simulateNetworkError = value;
    notifyListeners();
  }

  void clearCheckoutError() {
    if (_checkoutError != null) {
      _checkoutError = null;
      notifyListeners();
    }
  }

  void addItem(
    CanteenMenu menu, {
    int qty = 1,
    String catatan = '',
    bool takeAway = false,
    bool ekstraPedas = false,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menu.id == menu.id &&
          item.takeAway == takeAway &&
          item.ekstraPedas == ekstraPedas &&
          item.catatan == catatan.trim(),
    );

    if (existingIndex != -1) {
      _items[existingIndex].qty += qty;
    } else {
      _items.add(
        CartItem(
          menu: menu,
          qty: qty,
          catatan: catatan.trim(),
          takeAway: takeAway,
          ekstraPedas: ekstraPedas,
        ),
      );
    }
    _checkoutError = null;
    notifyListeners();
  }

  void incrementQty(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].qty++;
    notifyListeners();
  }

  void decrementQty(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Proses checkout asinkron dengan loading indicator & error handling (Tugas 8)
  Future<OrderRecord?> checkout({
    required String namaPemesan,
    required String metodeBayar,
  }) async {
    if (_items.isEmpty) {
      _checkoutError =
          'Keranjang masih kosong. Tambahkan menu terlebih dahulu.';
      notifyListeners();
      return null;
    }

    _isCheckingOut = true;
    _checkoutError = null;
    notifyListeners();

    try {
      // Simulasi proses pengiriman pesanan asinkron ke dapur kantin
      await Future.delayed(const Duration(seconds: 2));

      if (_simulateNetworkError) {
        throw TimeoutException(
          'Koneksi ke server kantin terputus (offline/timeout). Silakan coba lagi.',
        );
      }

      final now = DateTime.now();
      final kode = 'CC-${now.millisecondsSinceEpoch.toString().substring(7)}';
      final ringkasanItem =
          _items.map((e) => '${e.qty}x ${e.menu.nama}').join(', ');
      final order = OrderRecord(
        kodePesanan: kode,
        namaPemesan: namaPemesan,
        metodeBayar: metodeBayar,
        totalItem: totalItemCount,
        totalHarga: totalHarga,
        status: 'Diproses',
        waktuPesan: now,
      );

      // Integrasi Anggota 2 (Tugas 10): simpan transaksi ke SQLite (Android/iOS)
      // atau cache preview sementara saat dijalankan di Flutter Web (FlutLab)
      final transaksi = Transaksi(
        kodePesanan: order.kodePesanan,
        ringkasanItem: ringkasanItem,
        total: order.totalHarga.toDouble(),
        status: order.status,
        waktu: order.waktuPesan,
      );
      if (kIsWeb) {
        HistoryScreen.tambahPreviewWeb(transaksi);
      } else {
        await DbHelper.instance.insertTransaksi(transaksi);
      }

      _recentOrders.insert(0, order);
      _items.clear();
      return order;
    } on TimeoutException catch (e) {
      _checkoutError = e.message ?? 'Permintaan timeout.';
      return null;
    } catch (e) {
      _checkoutError = 'Gagal memproses checkout: $e';
      return null;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }
}
