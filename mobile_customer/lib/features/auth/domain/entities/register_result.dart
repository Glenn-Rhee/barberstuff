class RegisterResult {
  const RegisterResult({required this.id, required this.email});

  /// Id user baru, dipakai untuk verifikasi OTP.
  final String id;
  final String email;
}
