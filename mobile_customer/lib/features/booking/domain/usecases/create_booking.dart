import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingParams {
  const CreateBookingParams({
    required this.storeId,
    required this.capster,
    required this.serviceId,
    required this.bookingDate,
  });

  final String storeId;
  final SlotCapster capster;

  /// Server hanya menerima satu layanan per booking.
  final String serviceId;
  final DateTime bookingDate;
}

class CreateBooking implements UseCase<BookingRecord, CreateBookingParams> {
  const CreateBooking(this._repository);

  final BookingRepository _repository;

  @override
  Future<BookingRecord> call(CreateBookingParams params) =>
      _repository.createBooking(
        idStore: params.storeId,
        idCapster: params.capster.id,
        capsterName: params.capster.name,
        idService: params.serviceId,
        bookingDate: params.bookingDate,
      );
}
