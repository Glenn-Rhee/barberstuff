import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';

/// Parameter: `id_token` dari Google Sign-In.
class SignInWithGoogle implements UseCase<AuthProviderResult, String> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthProviderResult> call(String idToken) =>
      _repository.signInWithGoogle(idToken);
}
