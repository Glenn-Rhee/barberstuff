import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/models/forgot_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/oauth_register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/reset_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_request_api.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/verify_otp_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  /// Semua error jaringan diseragamkan jadi ApiException.
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  @override
  Future<RegisterResult> register(Registration registration) => _guard(
    () =>
        _remote.registerCredential(RegisterRequestApi.fromEntity(registration)),
  );

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String userId,
    required String otp,
  }) => _guard(
    () =>
        _remote.verifyCredential(VerifyOtpRequestApi(userId: userId, otp: otp)),
  );

  @override
  Future<AuthProviderResult> signInWithGoogle(String idToken) =>
      _guard(() => _remote.authProvider(idToken));

  @override
  Future<LoginResult> completeGoogleRegistration({
    required String name,
    required String tempToken,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) => _guard(
    () => _remote.registerOauth(
      OauthRegisterRequestApi(
        name: name,
        tempToken: tempToken,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      ),
    ),
  );

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) => _guard(
    () => _remote.loginCredential(
      LoginRequestApi(email: email, password: password),
    ),
  );

  @override
  Future<ForgotPasswordResult> forgotPassword(String email) => _guard(
    () => _remote.forgotPassword(ForgotPasswordRequestApi(email: email)),
  );

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _guard(
    () => _remote.resetPassword(
      ResetPasswordRequestApi(resetToken: resetToken, newPassword: newPassword),
    ),
  );
}
