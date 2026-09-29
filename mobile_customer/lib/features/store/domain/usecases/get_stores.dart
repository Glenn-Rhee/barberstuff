import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

class GetStoresParams {
  const GetStoresParams({this.name});

  /// Kata kunci nama atau alamat. null/kosong berarti semua cabang.
  final String? name;
}

class GetStores
    implements UseCase<CachedResult<List<StoreSummary>>, GetStoresParams> {
  const GetStores(this._repository);

  final StoreRepository _repository;

  @override
  Future<CachedResult<List<StoreSummary>>> call(GetStoresParams params) =>
      _repository.getStores(name: params.name);
}
