import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class RegisterAccount implements UseCase<RegisterResult, Registration> {
  const RegisterAccount(this._repository);

  final AuthRepository _repository;

  @override
  Future<RegisterResult> call(Registration registration) =>
      _repository.register(registration);
}
