// Sign in
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/login_response.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';

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
      token: res.map['token'] as String? ?? '',
      email: user['email'] as String? ?? email,
      role: user['role'] as String? ?? '',
    );
  }

  Future<StaffProfile> profile() async {
    return StaffProfile.fromJson((await _client.get('/profile/staff')).map);
  }
}
