class ForgotPasswordResult {
  const ForgotPasswordResult({required this.userId});

  /// Dipakai untuk verifikasi OTP reset kata sandi.
  final String userId;
}
