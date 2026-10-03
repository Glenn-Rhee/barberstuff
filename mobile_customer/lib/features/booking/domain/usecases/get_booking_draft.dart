import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

/// Sinkron supaya langkah awal alur booking sudah benar sejak frame pertama.
class GetBookingDraft implements SyncUseCase<BookingDraft, NoParams> {
  const GetBookingDraft(this._repository);

  final BookingRepository _repository;

  @override
  BookingDraft call(NoParams params) => _repository.readDraft();
}
