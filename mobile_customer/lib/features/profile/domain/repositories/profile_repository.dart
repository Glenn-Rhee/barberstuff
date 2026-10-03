import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';

abstract interface class ProfileRepository {
  /// Profil akun yang sedang login. Saat offline, profil terakhir dari cache
  /// dikembalikan dan ditandai [CachedResult.fromCache].
  Future<CachedResult<CustomerProfile>> getCustomerProfile();

  /// Hanya field yang tidak null yang dikirim. [imageKey] adalah `object_key`
  /// hasil unggah gambar, bukan URL.
  Future<CustomerProfile> updateCustomerProfile({
    String? name,
    String? phoneNumber,
    String? imageKey,
  });
}
