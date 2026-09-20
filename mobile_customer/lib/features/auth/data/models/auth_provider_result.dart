enum AuthProviderStatus { success, needCompleteProfile, unknown }

class AuthProviderResult {
  const AuthProviderResult({
    required this.email,
    required this.name,
    required this.status,
    this.accessToken,
    this.tempToken,
  });

  final String email;
  final String name;
  final AuthProviderStatus status;
  final String? accessToken;
  final String? tempToken;

  factory AuthProviderResult.fromJson(Map<String, dynamic> json) {
    return AuthProviderResult(
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
