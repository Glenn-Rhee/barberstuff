import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile_model.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._cache);

  final ProfileRemoteDataSource _remote;
  final AppCache _cache;

  CachedResult<CustomerProfile>? _fromCache() {
    final CachedPayload? cached = _cache.readJson(AppCache.keyCustomerProfile);
    final Map<String, dynamic>? raw = cached?.asMap;
    if (cached == null || raw == null) return null;

    return CachedResult<CustomerProfile>(
      CustomerProfileModel.fromJson(raw),
      fromCache: true,
      savedAt: cached.savedAt,
    );
  }

  @override
  Future<CachedResult<CustomerProfile>> getCustomerProfile() async {
    try {
      final Map<String, dynamic> raw = await _remote.getCustomerProfile();
      await _cache.writeJson(AppCache.keyCustomerProfile, raw);
      return CachedResult<CustomerProfile>(
        CustomerProfileModel.fromJson(raw),
        fromCache: false,
      );
    } catch (e) {
      final ApiException failure = DioClient.mapError(e);
      final CachedResult<CustomerProfile>? cached = _fromCache();
      if (cached != null) return cached;
      throw failure;
    }
  }

  /// [imageKey] adalah `object_key` hasil `ImageUploadService`, bukan URL.
  /// Backend menolak URL biasa di `image_url`.
  @override
  Future<CustomerProfile> updateCustomerProfile({
    String? name,
    String? phoneNumber,
    String? imageKey,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (imageKey != null) 'image_url': imageKey,
    };

    try {
      await _remote.updateCustomerProfile(body);
    } catch (e) {
      throw DioClient.mapError(e);
    }

    await _cache.remove(AppCache.keyCustomerProfile);

    final CachedResult<CustomerProfile> fresh = await getCustomerProfile();
    return fresh.data;
  }
}
