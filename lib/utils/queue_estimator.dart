/// Estimasi waktu tunggu pesanan di CerdasCanteen.
///
/// Rumus: (jumlah antrean x 3 menit) + (jumlah item x 2 menit).
int estimateWaitMinutes({required int queueLength, required int itemCount}) {
  return (queueLength * 3) + (itemCount * 2);
}
