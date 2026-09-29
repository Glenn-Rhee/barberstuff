import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

/// Parameter null menghapus kunci yang tersimpan.
class SaveBookingLock implements UseCase<void, BookingLock?> {
  const SaveBookingLock(this._repository);

  final BookingRepository _repository;

  @override
  Future<void> call(BookingLock? lock) => _repository.saveLock(lock);
}
