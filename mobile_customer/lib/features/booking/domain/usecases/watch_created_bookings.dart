import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

/// Aliran booking baru dari perangkat ini, supaya riwayat dan beranda bisa
/// langsung menyegarkan diri.
class WatchCreatedBookings
    implements SyncUseCase<Stream<BookingRecord>, NoParams> {
  const WatchCreatedBookings(this._repository);

  final BookingRepository _repository;

  @override
  Stream<BookingRecord> call(NoParams params) => _repository.createdBookings;
}
