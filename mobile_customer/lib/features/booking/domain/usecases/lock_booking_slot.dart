import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/booking_slot_params.dart';

class LockBookingSlot implements UseCase<void, BookingSlotParams> {
  const LockBookingSlot(this._repository);

  final BookingRepository _repository;

  @override
  Future<void> call(BookingSlotParams params) => _repository.lockBooking(
    idStore: params.storeId,
    idCapster: params.capsterId,
    bookingDate: params.bookingDate,
  );
}
