class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.email,
    required this.role,
  });

  final String token;
  final String email;
  final String role;
}
