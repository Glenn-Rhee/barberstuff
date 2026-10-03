import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

/// Parameter: email akun. Server mengirim OTP ke email itu.
class RequestPasswordReset implements UseCase<ForgotPasswordResult, String> {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Future<ForgotPasswordResult> call(String email) =>
      _repository.forgotPassword(email);
}
