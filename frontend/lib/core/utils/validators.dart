class Validators {
  const Validators._();

  // semua kolom jangan kosong
  static String? required(String? value, {String label = "Field ini"}) {
    if (value == null || value.trim().isEmpty) return "$label wajib diisi";
    return null;
  }

  // email valid
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email wajib diisi";
    }

    final RegExp re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

    if (!re.hasMatch(value.trim())) {
      return "Format email tidak valid";
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password wajib diisi';

    if (value.length < 5) return "Password minimal 5 karakter";

    return null;
  }

  static String? phoneNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor telepon wajib diisi';
    final String p = v.trim();
    if (p.length < 9) return 'Nomor telepon minimal 9 digit';
    if (p.length > 15) return 'Nomor telepon maksimal 15 digit';
    if (!RegExp(r'^[0-9]+$').hasMatch(p)) return 'Hanya boleh angka';
    return null;
  }
}
