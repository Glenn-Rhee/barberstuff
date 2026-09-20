class VerifyOtpRequestApi {
  const VerifyOtpRequestApi({required this.userId, required this.otp});

  final String userId;
  final String otp;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'otp': otp,
  };
}
