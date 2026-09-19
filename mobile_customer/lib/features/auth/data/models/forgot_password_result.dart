class ForgotPasswordResult {
  const ForgotPasswordResult({required this.userId});

  final String userId;

  factory ForgotPasswordResult.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResult(userId: (json['user_id'] as String?) ?? '');
}
