import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

/// Parameter: user sudah menyetujui syarat booking atau belum.
class SaveBookingTerms implements UseCase<void, bool> {
  const SaveBookingTerms(this._repository);

  final BookingRepository _repository;

  @override
  Future<void> call(bool agreed) => _repository.saveTermsAgreed(agreed);
}
