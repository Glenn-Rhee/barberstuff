import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class CompleteGoogleRegistrationParams {
  const CompleteGoogleRegistrationParams({
    required this.name,
    required this.tempToken,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
  });

  final String name;
  final String tempToken;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
}

class CompleteGoogleRegistration
    implements UseCase<LoginResult, CompleteGoogleRegistrationParams> {
  const CompleteGoogleRegistration(this._repository);

  final AuthRepository _repository;

  @override
  Future<LoginResult> call(CompleteGoogleRegistrationParams params) =>
      _repository.completeGoogleRegistration(
        name: params.name,
        tempToken: params.tempToken,
        phoneNumber: params.phoneNumber,
        dateOfBirth: params.dateOfBirth,
        gender: params.gender,
      );
}
