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
}
