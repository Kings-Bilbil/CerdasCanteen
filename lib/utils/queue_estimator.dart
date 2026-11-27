/// Estimasi waktu tunggu pesanan di CerdasCanteen.
///
/// Rumus: (jumlah antrean x [minutesPerQueue]) + (jumlah item x [minutesPerItem]).
/// Aturan bisnis:
/// - nilai negatif ditolak,
/// - pesanan tanpa item ditolak.
library;

/// Menit tambahan untuk setiap orang yang sedang mengantre di depan kita.
const int minutesPerQueue = 3;

/// Menit tambahan untuk setiap item yang dipesan (waktu penyajian).
const int minutesPerItem = 2;

/// Menghitung estimasi waktu tunggu dalam menit.
///
/// Melempar [ArgumentError] bila [queueLength]/[itemCount] negatif, atau bila
/// [itemCount] bernilai 0 (pesanan kosong tidak valid).
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  if (queueLength < 0 || itemCount < 0) {
    throw ArgumentError('Nilai tidak boleh negatif');
  }
  if (itemCount == 0) {
    throw ArgumentError('Pesanan harus berisi minimal 1 item');
  }
  return (queueLength * minutesPerQueue) + (itemCount * minutesPerItem);
}
