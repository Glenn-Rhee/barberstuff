import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/verify_otp_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({required this.userId, required this.otp});

  final String userId;
  final String otp;
}

class VerifyOtp implements UseCase<VerifyOtpResult, VerifyOtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<VerifyOtpResult> call(VerifyOtpParams params) =>
      _repository.verifyOtp(userId: params.userId, otp: params.otp);
}
