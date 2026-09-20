class VerifyOtpResult {
  const VerifyOtpResult({this.resetToken});

  final String? resetToken;

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResult(resetToken: json['reset_token'] as String?);
}
