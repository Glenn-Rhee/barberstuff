import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams({
    required this.resetToken,
    required this.newPassword,
  });

  /// Didapat dari verifikasi OTP lupa kata sandi.
  final String resetToken;
  final String newPassword;
}

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(ResetPasswordParams params) => _repository.resetPassword(
    resetToken: params.resetToken,
    newPassword: params.newPassword,
  );
}
