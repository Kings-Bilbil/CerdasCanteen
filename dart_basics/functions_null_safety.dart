// Tugas 2c - Dart Basics: Functions & Null Safety
//
// ignore_for_file: avoid_print
//
// Skenario: CerdasCanteen perlu menghitung total belanja mahasiswa beserta
// diskon, dengan catatan pesanan yang OPSIONAL (boleh null).
//
// Jalankan: dart run dart_basics/functions_null_safety.dart

/// Diskon member 10% berlaku mulai subtotal Rp50.000.
const double membershipDiscountRate = 0.10;
const int membershipMinSubtotal = 50000;

/// Total belanja setelah diskon.
///
/// Parameter `catatan` opsional dan nullable (`String?`) - inilah contoh
/// null safety: nilainya boleh `null` dan wajib dicek sebelum dipakai.
///
/// `isMember` memakai named parameter dengan nilai default `false`.
double hitungTotal(
  List<int> hargaItem, {
  bool isMember = false,
  String? catatan,
}) {
  if (hargaItem.isEmpty) {
    throw ArgumentError('Keranjang tidak boleh kosong');
  }

  // Null-aware + null-coalescing operator.
  final int subtotal = hargaItem.reduce((a, b) => a + b);

  // Null safety: `catatan?.trim()` tidak error walau catatan == null.
  final String catatanBersih = catatan?.trim() ?? '(tanpa catatan)';
  final bool catatanKosong = catatanBersih.isEmpty;

  final bool dapatDiskon = isMember && subtotal >= membershipMinSubtotal;
  final double diskon = dapatDiskon ? subtotal * membershipDiscountRate : 0.0;

  // Cascade log ke konsol supaya mudah di-screenshot.
  print('--- Struk CerdasCanteen ---');
  print('Item          : ${hargaItem.length} (${hargaItem.join(', ')})');
  print('Subtotal      : Rp${subtotal.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]}.',
      )}');
  print('Status member : ${isMember ? 'Ya' : 'Tidak'}');
  print('Diskon        : Rp${diskon.toStringAsFixed(0)}'
      '${dapatDiskon ? ' (10% member)' : ''}');
  print('Catatan       : ${catatanKosong ? '(kosong)' : catatanBersih}');

  return subtotal - diskon;
}

void main() {
  // 1. Pesanan lengkap dengan catatan.
  final double total1 = hitungTotal(
    [15000, 12000, 8000],
    isMember: false,
    catatan: '  Tanpa sambal, nasi setengah  ',
  );
  print('Total akhir   : Rp${total1.toStringAsFixed(0)}');
  print('');

  // 2. Pesanan tanpa catatan (null) -> null safety tidak crash.
  final double total2 = hitungTotal([45000, 10000], isMember: true);
  print('Total akhir   : Rp${total2.toStringAsFixed(0)}');
  print('');

  // 3. Member tapi belum mencapai batas diskon.
  final double total3 = hitungTotal([20000, 15000], isMember: true, catatan: '');
  print('Total akhir   : Rp${total3.toStringAsFixed(0)}');
  print('');

  // 4. Error ditangani dengan try-catch: keranjang kosong.
  try {
    hitungTotal([]);
  } on ArgumentError catch (e) {
    print('Error tertangani: ${e.message}');
  }
}
