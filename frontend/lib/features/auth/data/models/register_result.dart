class RegisterResult {
  const RegisterResult({required this.id, required this.email});

  final String id;
  final String email;

  factory RegisterResult.fromJson(Map<String, dynamic> json) => RegisterResult(
        id: (json['id'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
      );
}