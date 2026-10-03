import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';

abstract interface class HistoryRepository {
  /// Semua booking akun yang sedang login (akan datang, selesai, batal),
  /// terbaru di depan.
  Future<List<BookingRecord>> getBookings();

  Future<void> submitReview(BookingRecord booking, ReviewDraft draft);
}
