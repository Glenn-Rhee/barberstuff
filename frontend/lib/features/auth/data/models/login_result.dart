class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.role,
  });

  final String accessToken;
  final String userId;
  final String email;
  final String role;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user =
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return LoginResult(
      accessToken: (json['access_token'] as String?) ?? '',
      userId: (user['user_id'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      role: (user['role'] as String?) ?? '',
    );
  }
}
