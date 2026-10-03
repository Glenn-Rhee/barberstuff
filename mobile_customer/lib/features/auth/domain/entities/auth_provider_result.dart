enum AuthProviderStatus { success, needCompleteProfile, unknown }

/// Hasil masuk dengan Google. [needCompleteProfile] berarti akun baru dan
/// harus melengkapi profil memakai [tempToken] sebelum dapat [accessToken].
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
}
