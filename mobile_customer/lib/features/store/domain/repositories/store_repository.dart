import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';

abstract interface class StoreRepository {
  /// Daftar cabang. Saat offline, daftar terakhir dari cache ikut dicari
  /// dengan [name] dan ditandai [CachedResult.fromCache].
  Future<CachedResult<List<StoreSummary>>> getStores({String? name});

  Future<StoreDetail> getStoreDetail(String id);

  Future<List<CapsterItem>> getCapsters(String idStore);

  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  });
}
