/// Validasi form login & register CerdasCanteen.
///
/// Fungsi murni (tanpa context) agar mudah diuji dengan unit test.
class Validators {
  /// Email wajib diisi dan berformat valid.
  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Email wajib diisi';
    // Sederhana namun cukup: satu '@', domain dengan titik.
    final RegExp pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  /// Password minimal 8 karakter.
  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Password wajib diisi';
    if (v.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  /// Nama wajib diisi, tidak hanya spasi.
  static String? nama(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Nama wajib diisi';
    if (v.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  /// Konfirmasi password harus sama dengan password.
  static String? konfirmasiPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != password) return 'Konfirmasi password tidak sama';
    return null;
  }

  /// Boolean praktis untuk tombol submit.
  static bool isFormValid(List<String?> errors) =>
      errors.every((String? e) => e == null);
}

/// Aturan bisnis checkout sederhana untuk menilai proses sistem
/// (Tugas 13: "apakah checkout dengan keranjang kosong ditolak?").
class CheckoutRules {
  /// Mengembalikan pesan error, atau null bila checkout sah.
  static String? validateCart({required int itemCount}) {
    if (itemCount <= 0) {
      return 'Keranjang kosong, tidak bisa checkout';
    }
    return null;
  }

  static bool canCheckout({required int itemCount}) =>
      validateCart(itemCount: itemCount) == null;
}
