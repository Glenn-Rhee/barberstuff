import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/repositories/history_repository.dart';

class GetBookingHistory implements UseCase<List<BookingRecord>, NoParams> {
  const GetBookingHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<List<BookingRecord>> call(NoParams params) =>
      _repository.getBookings();
}
