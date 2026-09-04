class ForgotPasswordResult {
  final String userId;

  const ForgotPasswordResult({required this.userId});

  factory ForgotPasswordResult.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResult(userId: (json['user_id'] as String?) ?? '');
  }
}