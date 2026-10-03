import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

class GetStoreSlotsParams {
  const GetStoreSlotsParams({required this.storeId, required this.date});

  final String storeId;
  final DateTime date;
}

class GetStoreSlots implements UseCase<StoreSlots, GetStoreSlotsParams> {
  const GetStoreSlots(this._repository);

  final BookingRepository _repository;

  @override
  Future<StoreSlots> call(GetStoreSlotsParams params) =>
      _repository.getStoreSlots(idStore: params.storeId, date: params.date);
}
