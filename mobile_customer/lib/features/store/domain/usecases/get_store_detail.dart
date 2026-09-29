import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

/// Parameter: id cabang.
class GetStoreDetail implements UseCase<StoreDetail, String> {
  const GetStoreDetail(this._repository);

  final StoreRepository _repository;

  @override
  Future<StoreDetail> call(String storeId) =>
      _repository.getStoreDetail(storeId);
}
