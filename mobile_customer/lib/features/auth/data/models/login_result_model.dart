import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';

class LoginResultModel extends LoginResult {
  const LoginResultModel({
    required super.accessToken,
    required super.userId,
    required super.email,
    required super.role,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user =
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return LoginResultModel(
      accessToken: (json['access_token'] as String?) ?? '',
      userId: (user['user_id'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      role: (user['role'] as String?) ?? '',
    );
  }
}
