import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

/// Cabang tanpa jaringan. Tes yang butuh detail cabang meng-override
/// [getStoreDetail].
class FakeStoreRepository implements StoreRepository {
  static const StoreSummary sampleStore = StoreSummary(
    id: 'store-1',
    name: 'Barberstuff Kemang Raya',
    address: 'Jl. Metro Pondok Indah No. 12',
    phoneNumber: '081234567890',
    bannerUrl: '',
    storeType: 'lite',
    status: 'open',
    avgRating: 4.8,
    totalCapster: 3,
    totalService: 5,
    totalPackage: 2,
  );

  static const ServiceItem sampleService = ServiceItem(
    id: 'service-1',
    name: 'Cukur Rambut',
    price: 45000,
    idStore: 'store-1',
    type: ProductType.service,
    status: 'active',
    description: 'Potong rambut standar, cuci rambut, dan pijat ringan.',
  );

  @override
  Future<CachedResult<List<StoreSummary>>> getStores({String? name}) async =>
      const CachedResult<List<StoreSummary>>(<StoreSummary>[
        sampleStore,
      ], fromCache: false);

  @override
  Future<StoreDetail> getStoreDetail(String id) =>
      throw UnimplementedError('override getStoreDetail di tes');

  @override
  Future<List<CapsterItem>> getCapsters(String idStore) async =>
      const <CapsterItem>[];

  @override
  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  }) async => <ServiceItem>[sampleService];
}
