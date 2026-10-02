import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/login_response.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';

// Login dan profil staff yang sedang login
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      '/auth/login/credential',
      data: {'email': email, 'password': password},
    );
    final user = (res.map['user'] as Map? ?? const {}).cast<String, dynamic>();
    return LoginResponse(
      // backend kirim token di key access_token
      token: res.map['access_token'] as String? ?? '',
      email: user['email'] as String? ?? email,
      role: user['role'] as String? ?? '',
    );
  }

  Future<StaffProfile> profile() async {
    return StaffProfile.fromJson((await _client.get('/profile/staff')).map);
  }

  // Ganti nama + password akun sendiri (PATCH /staff/{id}), tanpa OTP
  Future<void> updateAccount({
    required String staffId,
    required String name,
    required String password,
  }) => _client.patch(
    '/staff/$staffId',
    data: {'name': name, 'password': password},
  );
}
