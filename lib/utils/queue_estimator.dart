/// Estimasi waktu tunggu pesanan di CerdasCanteen.
///
/// Rumus: (jumlah antrean x 3 menit) + (jumlah item x 2 menit).
/// Aturan bisnis:
/// - nilai negatif ditolak,
/// - pesanan tanpa item ditolak.
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  if (queueLength < 0 || itemCount < 0) {
    throw ArgumentError('Nilai tidak boleh negatif');
  }
  if (itemCount == 0) {
    throw ArgumentError('Pesanan harus berisi minimal 1 item');
  }
  return (queueLength * 3) + (itemCount * 2);
}
