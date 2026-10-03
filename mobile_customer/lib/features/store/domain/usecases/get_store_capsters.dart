import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

/// Parameter: id cabang.
class GetStoreCapsters implements UseCase<List<CapsterItem>, String> {
  const GetStoreCapsters(this._repository);

  final StoreRepository _repository;

  @override
  Future<List<CapsterItem>> call(String storeId) =>
      _repository.getCapsters(storeId);
}
