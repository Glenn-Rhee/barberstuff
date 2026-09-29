import 'package:mobile_barberstuff/features/auth/domain/entities/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/verify_otp_result.dart';

abstract interface class AuthRepository {
  /// Mendaftar dengan email; server mengirim OTP ke email itu.
  Future<RegisterResult> register(Registration registration);

  Future<VerifyOtpResult> verifyOtp({
    required String userId,
    required String otp,
  });

  Future<AuthProviderResult> signInWithGoogle(String idToken);

  /// Melengkapi profil akun Google baru memakai `temp_token`.
  Future<LoginResult> completeGoogleRegistration({
    required String name,
    required String tempToken,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  });

  Future<LoginResult> login({required String email, required String password});

  /// Mengirim OTP reset kata sandi ke [email].
  Future<ForgotPasswordResult> forgotPassword(String email);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
