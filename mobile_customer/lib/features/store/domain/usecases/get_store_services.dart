import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';

class GetStoreServicesParams {
  const GetStoreServicesParams({required this.storeId, required this.type});

  final String storeId;
  final ProductType type;
}

/// Layanan satuan atau paket sebuah cabang, tergantung [GetStoreServicesParams.type].
class GetStoreServices
    implements UseCase<List<ServiceItem>, GetStoreServicesParams> {
  const GetStoreServices(this._repository);

  final StoreRepository _repository;

  @override
  Future<List<ServiceItem>> call(GetStoreServicesParams params) =>
      _repository.getServices(idStore: params.storeId, type: params.type);
}
