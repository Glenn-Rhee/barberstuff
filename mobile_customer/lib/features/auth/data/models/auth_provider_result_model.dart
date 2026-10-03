import 'package:mobile_barberstuff/features/auth/domain/entities/auth_provider_result.dart';

class AuthProviderResultModel extends AuthProviderResult {
  const AuthProviderResultModel({
    required super.email,
    required super.name,
    required super.status,
    super.accessToken,
    super.tempToken,
  });

  factory AuthProviderResultModel.fromJson(Map<String, dynamic> json) {
    return AuthProviderResultModel(
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      status: _statusOf(json['status'] as String?),
      accessToken: json['access_token'] as String?,
      tempToken: json['temp_token'] as String?,
    );
  }

  static AuthProviderStatus _statusOf(String? raw) {
    switch (raw) {
      case 'SUCCESS':
        return AuthProviderStatus.success;
      case 'NEED_COMPLETE_PROFILE':
        return AuthProviderStatus.needCompleteProfile;
      default:
        return AuthProviderStatus.unknown;
    }
  }
}
