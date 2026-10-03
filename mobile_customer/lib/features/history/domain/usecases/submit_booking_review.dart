import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/repositories/history_repository.dart';

class SubmitBookingReviewParams {
  const SubmitBookingReviewParams({required this.booking, required this.draft});

  final BookingRecord booking;
  final ReviewDraft draft;
}

class SubmitBookingReview implements UseCase<void, SubmitBookingReviewParams> {
  const SubmitBookingReview(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call(SubmitBookingReviewParams params) =>
      _repository.submitReview(params.booking, params.draft);
}
