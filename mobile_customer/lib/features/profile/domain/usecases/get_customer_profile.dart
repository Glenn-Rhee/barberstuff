import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/repositories/profile_repository.dart';

class GetCustomerProfile
    implements UseCase<CachedResult<CustomerProfile>, NoParams> {
  const GetCustomerProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<CachedResult<CustomerProfile>> call(NoParams params) =>
      _repository.getCustomerProfile();
}
