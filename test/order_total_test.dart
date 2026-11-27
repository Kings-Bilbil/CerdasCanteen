import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_perak/models/canteen_item.dart';
import 'package:tubes_perak/providers/cart_provider.dart';

// ============================================================================
// UNIT TEST — total harga keranjang (kode asli: lib/providers/cart_provider.dart
// dan lib/models/canteen_item.dart)
//
// Cara membaca kegagalan:
//   "Expected: <45000> Actual: <...>" -> rumus subtotal/total berubah.
//   Setiap expect memakai `reason:` berisi INPUT -> HARAPAN -> PENYEBAB UMUM.
// ============================================================================

CanteenMenu _menu({
  String id = 'M1',
  String nama = 'Nasi Goreng',
  int harga = 15000,
  int estimasiMenit = 5,
}) {
  return CanteenMenu(
    id: id,
    nama: nama,
    harga: harga,
    kategori: 'Makanan',
    deskripsi: 'Deskripsi',
    gambarUrl: '',
    estimasiMenit: estimasiMenit,
  );
}

void main() {
  group('CartItem.subtotal', () {
    test('harga x qty tanpa take-away', () {
      final CartItem item = CartItem(menu: _menu(), qty: 2);
      expect(
        item.subtotal,
        30000,
        reason: 'INPUT harga=15000, qty=2, takeAway=false -> HARAP 30000. '
            'Bila gagal: getter subtotal bukan hargaSatuanFinal * qty.',
      );
    });

    test('take-away menambah biaya kemasan Rp1.000 per porsi', () {
      final CartItem item = CartItem(menu: _menu(), qty: 2, takeAway: true);
      expect(
        item.biayaKemasan,
        1000,
        reason: 'INPUT takeAway=true -> HARAP biaya kemasan 1000.',
      );
      expect(
        item.subtotal,
        32000,
        reason: 'INPUT (15000+1000) x 2 -> HARAP 32000. '
            'Bila 30000: biaya kemasan tidak ikut dihitung.',
      );
    });
  });

  group('CartProvider.totalHarga', () {
    test('menjumlahkan subtotal semua item', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_menu(id: 'M1', harga: 15000), qty: 2); // 30000
      cart.addItem(_menu(id: 'M2', nama: 'Es Teh', harga: 5000), qty: 3);

      expect(
        cart.totalHarga,
        45000,
        reason: 'INPUT 2 item (30000 + 15000) -> HARAP 45000. '
            'Bila 35000: qty salah satu item diabaikan.',
      );
      expect(
        cart.totalItemCount,
        5,
        reason: 'totalItemCount menghitung KUANTITAS (2+3=5), '
            'bukan jumlah baris. Bila 2: yang dipakai items.length.',
      );
    });

    test('keranjang kosong bernilai 0', () {
      final CartProvider cart = CartProvider();
      expect(
        cart.totalHarga,
        0,
        reason: 'Keranjang kosong tidak boleh error. '
            'Bila gagal: fold tanpa initialValue.',
      );
      expect(
        cart.isEmpty,
        isTrue,
        reason: 'isEmpty dipakai UI untuk menolak checkout.',
      );
    });

    test('menu sama + opsi sama digabung, bukan jadi baris baru', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_menu(id: 'M1'), qty: 1);
      cart.addItem(_menu(id: 'M1'), qty: 2);

      expect(
        cart.items.length,
        1,
        reason: 'INPUT menu sama 2x -> HARAP 1 baris. '
            'Bila 2: logika indexWhere penggabungan rusak.',
      );
      expect(
        cart.items.first.qty,
        3,
        reason: 'qty harus terakumulasi 1+2=3.',
      );
    });

    test('menu sama tapi opsi berbeda tetap jadi baris terpisah', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_menu(id: 'M1'), qty: 1);
      cart.addItem(_menu(id: 'M1'), qty: 1, takeAway: true);

      expect(
        cart.items.length,
        2,
        reason: 'INPUT menu sama, takeAway beda -> HARAP 2 baris. '
            'Bila 1: opsi tidak ikut jadi pembeda.',
      );
    });
  });

  group('CartProvider.estimasiTotalMenit', () {
    test('keranjang kosong = 0 menit', () {
      expect(
        CartProvider().estimasiTotalMenit,
        0,
        reason: 'Keranjang kosong -> HARAP 0. Bila error: guard isEmpty hilang.',
      );
    });

    test('ambil estimasi terlama + 2 menit per item tambahan', () {
      final CartProvider cart = CartProvider();
      // estimasiMenit 7 dan 5 -> terlama 7; total item 3 -> (3-1)*2 = 4
      cart.addItem(_menu(id: 'M1', estimasiMenit: 7), qty: 2);
      cart.addItem(_menu(id: 'M2', nama: 'Es Teh', estimasiMenit: 5), qty: 1);

      expect(
        cart.estimasiTotalMenit,
        11,
        reason: 'INPUT estimasi 7 & 5, total item 3 -> HARAP 7 + (3-1)*2 = 11. '
            'Bila 12: dipakai estimasi terbesar 7 + 3*2 tanpa -1.',
      );
    });
  });

  group('CartProvider - penilaian proses sistem', () {
    test('checkout keranjang kosong ditolak dengan pesan jelas', () async {
      final CartProvider cart = CartProvider();

      final result = await cart.checkout(
        namaPemesan: 'Mahasiswa',
        metodeBayar: 'Tunai',
      );

      expect(
        result,
        isNull,
        reason: 'INPUT keranjang kosong -> HARAP checkout mengembalikan null '
            '(tidak ada pesanan dibuat).',
      );
      expect(
        cart.checkoutError,
        'Keranjang masih kosong. Tambahkan menu terlebih dahulu.',
        reason: 'Pesan error harus eksplisit agar UI bisa menampilkan alasan.',
      );
      expect(
        cart.isCheckingOut,
        isFalse,
        reason: 'Checkout yang ditolak tidak boleh meninggalkan loading aktif.',
      );
    });

    test('decrement pada qty 1 menghapus baris', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_menu(id: 'M1'), qty: 1);
      cart.decrementQty(0);

      expect(
        cart.isEmpty,
        isTrue,
        reason: 'INPUT qty=1 lalu decrement -> HARAP item dihapus. '
            'Bila qty jadi 0: baris kosong tertinggal di keranjang.',
      );
    });

    test('index di luar batas diabaikan, tidak melempar error', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_menu(id: 'M1'), qty: 1);

      expect(
        () => cart.removeItem(99),
        returnsNormally,
        reason: 'INPUT index 99 -> HARAP diabaikan. '
            'Bila RangeError: guard batas index hilang.',
      );
      expect(
        cart.items.length,
        1,
        reason: 'Item yang ada tidak boleh ikut terhapus.',
      );
    });
  });
}
