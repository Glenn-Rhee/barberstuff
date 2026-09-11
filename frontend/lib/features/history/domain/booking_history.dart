enum BookingStatus { booked, progress, completed, canceled }

enum HistoryTab { upcoming, done, canceled }

enum ReviewTarget { capster, cashier, store }

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

  static BookingStatus statusFromJson(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'progress':
        return BookingStatus.progress;
      case 'completed':
        return BookingStatus.completed;
      case 'canceled':
        return BookingStatus.canceled;
      default:
        return BookingStatus.booked;
    }
  }

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      id: '${json['id'] ?? ''}',
      serviceName: '${json['service_name'] ?? ''}',
      storeName: '${json['store_name'] ?? ''}',
      date:
          DateTime.tryParse('${json['scheduled_at'] ?? ''}')?.toLocal() ??
          DateTime.now(),
      price: (json['total_price'] as num?)?.round() ?? 0,
      status: statusFromJson(json['status_booking'] as String?),
      reviewScore: (json['review_score'] as num?)?.toDouble(),
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

  List<Map<String, dynamic>> toRatingPayload() {
    return <Map<String, dynamic>>[
      <String, dynamic>{'type': 'capster', 'score': capster},
      <String, dynamic>{'type': 'staff', 'score': cashier},
      <String, dynamic>{'type': 'store', 'score': store},
    ].map((Map<String, dynamic> item) {
      if (message.trim().isNotEmpty) item['message'] = message.trim();
      return item;
    }).toList(growable: false);
  }
}
