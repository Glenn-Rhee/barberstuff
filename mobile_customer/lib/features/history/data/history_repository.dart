import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

class HistoryRepository extends ChangeNotifier {
  HistoryRepository(this._journal) {
    _journal.addListener(notifyListeners);
  }

  final BookingJournal _journal;

  Future<List<BookingHistory>> getHistory() async {
    final DateTime now = DateTime.now();

    return _journal.records
        .map((BookingRecord r) => r.toHistory(now))
        .toList(growable: false);
  }

  Future<void> submitReview(String bookingId, ReviewDraft draft) async {
    await _journal.setReview(
      bookingId,
      BookingReview(
        capster: draft.capster,
        cashier: draft.cashier,
        store: draft.store,
        message: draft.message.trim(),
      ),
    );
  }

  /// Ulasan tersimpan, dipakai untuk membuka sheet dalam mode baca.
  ReviewDraft? reviewOf(String bookingId) {
    final BookingReview? review = _journal.byId(bookingId)?.review;
    if (review == null) return null;

    return ReviewDraft(
      capster: review.capster,
      cashier: review.cashier,
      store: review.store,
      message: review.message,
    );
  }

  @override
  void dispose() {
    _journal.removeListener(notifyListeners);
    super.dispose();
  }
}
