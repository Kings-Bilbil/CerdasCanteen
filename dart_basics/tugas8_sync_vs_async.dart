/// Tugas 8 (Sub-CPMK0537) — Perbandingan Eksekusi Sinkron vs Asinkron di Dart
/// Domain: CerdasCanteen (Simulasi loading data menu & proses pesanan kantin)

/// 1. SINKRON (Blocking): loop menahan thread utama selama 5 detik penuh
void prosesSinkron(String namaProses) {
  print('[SYNC]  Mulai: $namaProses (blocking 5 detik...)');
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed.inSeconds < 5) {
    // Menahan Event Loop selama 5 detik — proses lain tidak bisa berjalan
  }
  stopwatch.stop();
  print('[SYNC]  Selesai: $namaProses (${stopwatch.elapsed.inSeconds} detik)');
}

/// 2. ASINKRON (Non-Blocking): menggunakan Future.delayed agar tidak menahan UI
Future<void> prosesAsinkron(String namaProses) async {
  print('[ASYNC] Mulai: $namaProses (tunggu 5 detik tanpa blocking...)');
  await Future.delayed(const Duration(seconds: 5));
  print('[ASYNC] Selesai: $namaProses (selesai setelah 5 detik)');
}

Future<void> main() async {
  print('=======================================================');
  print('BAGIAN 1: EKSEKUSI SINKRON (BLOCKING 5 DETIK)');
  print('=======================================================');
  print('[1] Mahasiswa membuka halaman menu CerdasCanteen');
  prosesSinkron('Ambil daftar menu kantin');
  // Baris [2] BARU jalan setelah 5 detik selesai (UI terasa freeze/macet)
  print('[2] User mencoba scroll halaman menu (terhambat 5 detik!)');

  print('\n=======================================================');
  print('BAGIAN 2: EKSEKUSI ASINKRON (NON-BLOCKING / EVENT LOOP)');
  print('=======================================================');
  print('[1] Mahasiswa membuka halaman menu CerdasCanteen');
  // Memicu Future tanpa langsung memblokir baris berikutnya
  final Future<void> tugasMenu = prosesAsinkron('Ambil daftar menu dari API');
  // Baris [2] LANGSUNG jalan tanpa menunggu 5 detik!
  print('[2] User tetap bisa scroll & klik UI saat loading berjalan!');
  print('[3] Loading indicator ditampilkan di layar...');

  // Menunggu Future selesai agar hasil akhir tercetak rapi
  await tugasMenu;
  print('[4] Data menu tampil di layar CerdasCanteen.');
}
