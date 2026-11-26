/// Format rupiah sederhana: 15000 -> "Rp15.000".
String formatRupiah(int amount) {
  final bool negative = amount < 0;
  final String digits = amount.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}Rp$buffer';
}

/// Format menit menjadi teks ramah: "13 menit", "1 jam 5 menit".
String formatEstimasiMenit(int minutes) {
  if (minutes < 60) return '$minutes menit';
  final int jam = minutes ~/ 60;
  final int sisa = minutes % 60;
  return sisa == 0 ? '$jam jam' : '$jam jam $sisa menit';
}
