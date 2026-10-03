/// Isian daftar akun baru. Disimpan sampai OTP terverifikasi supaya kirim
/// ulang OTP cukup mendaftar ulang dengan isian yang sama.
class Registration {
  const Registration({
    required this.name,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.password,
    this.imageUrl,
  });

  final String name;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String email;
  final String password;
  final String? imageUrl;
}
