import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(this._remote, this._cache);

  final StoreRemoteDataSource _remote;
  final AppCache _cache;

  @override
  Future<CachedResult<List<StoreSummary>>> getStores({String? name}) async {
    try {
      final List<StoreSummary> stores = await _remote.getStores(name: name);
      if (name == null || name.isEmpty) {
        await _cache.writeJson(
          AppCache.keyStores,
          stores
              .map((StoreSummary s) => StoreSummaryModel.fromEntity(s).toJson())
              .toList(growable: false),
        );
      }
      return CachedResult<List<StoreSummary>>(stores, fromCache: false);
    } catch (e) {
      final ApiException failure = DioClient.mapError(e);
      final CachedPayload? cached = _cache.readJson(AppCache.keyStores);

      if (cached != null && cached.asList.isNotEmpty) {
        final List<StoreSummary> stores = cached.asList
            .map(StoreSummaryModel.fromJson)
            .toList(growable: false);

        final String needle = (name ?? '').toLowerCase();
        return CachedResult<List<StoreSummary>>(
          needle.isEmpty
              ? stores
              : stores
                    .where(
                      (StoreSummary s) =>
                          s.name.toLowerCase().contains(needle) ||
                          s.address.toLowerCase().contains(needle),
                    )
                    .toList(growable: false),
          fromCache: true,
          savedAt: cached.savedAt,
        );
      }

      throw failure;
    }
  }

  @override
  Future<StoreDetail> getStoreDetail(String id) async {
    try {
      return await _remote.getStoreDetail(id);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  @override
  Future<List<CapsterItem>> getCapsters(String idStore) async {
    try {
      return await _remote.getCapsters(idStore);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  @override
  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  }) async {
    try {
      return await _remote.getServices(idStore: idStore, type: type);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
