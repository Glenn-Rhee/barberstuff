import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/repositories/profile_repository.dart';

class UpdateCustomerProfileParams {
  const UpdateCustomerProfileParams({
    this.name,
    this.phoneNumber,
    this.imageKey,
  });

  final String? name;
  final String? phoneNumber;

  /// `object_key` hasil unggah gambar, bukan URL.
  final String? imageKey;
}

/// Mengembalikan profil terbaru dari server setelah perubahan tersimpan.
class UpdateCustomerProfile
    implements UseCase<CustomerProfile, UpdateCustomerProfileParams> {
  const UpdateCustomerProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<CustomerProfile> call(UpdateCustomerProfileParams params) =>
      _repository.updateCustomerProfile(
        name: params.name,
        phoneNumber: params.phoneNumber,
        imageKey: params.imageKey,
      );
}
