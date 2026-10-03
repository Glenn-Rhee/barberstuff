import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginWithEmail implements UseCase<LoginResult, LoginParams> {
  const LoginWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<LoginResult> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password);
}
