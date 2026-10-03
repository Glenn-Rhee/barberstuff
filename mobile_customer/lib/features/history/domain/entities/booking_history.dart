import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';

enum HistoryTab { upcoming, done, canceled }

enum ReviewTarget { capster, cashier, store }

/// Satu baris di halaman riwayat.
class BookingHistory {
  const BookingHistory({
    required this.id,
    required this.serviceName,
    required this.storeName,
    required this.date,
    required this.price,
    required this.status,
    this.reviewScore,
  });

  factory BookingHistory.fromRecord(BookingRecord record, DateTime now) =>
      BookingHistory(
        id: record.id,
        serviceName: record.serviceName,
        storeName: record.storeName,
        date: record.scheduledAt,
        price: record.totalPrice.round(),
        status: record.statusAt(now),
        reviewScore: record.reviewScore,
      );

  final String id;
  final String serviceName;
  final String storeName;
  final DateTime date;
  final int price;
  final BookingStatus status;
  final double? reviewScore;

  bool get isReviewed => reviewScore != null;

  HistoryTab get tab {
    switch (status) {
      case BookingStatus.booked:
      case BookingStatus.progress:
        return HistoryTab.upcoming;
      case BookingStatus.completed:
        return HistoryTab.done;
      case BookingStatus.canceled:
        return HistoryTab.canceled;
    }
  }

  BookingHistory copyWith({double? reviewScore}) {
    return BookingHistory(
      id: id,
      serviceName: serviceName,
      storeName: storeName,
      date: date,
      price: price,
      status: status,
      reviewScore: reviewScore ?? this.reviewScore,
    );
  }
}

class ReviewDraft {
  const ReviewDraft({
    required this.capster,
    required this.cashier,
    required this.store,
    required this.message,
  });

  final int capster;
  final int cashier;
  final int store;
  final String message;

  bool get isComplete => capster > 0 && cashier > 0 && store > 0;

  double get average => (capster + cashier + store) / 3;
}
