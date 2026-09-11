import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

class HistoryRepository extends ChangeNotifier {
  HistoryRepository();

  List<BookingHistory> _items = _dummy();

  static List<BookingHistory> _dummy() {
    final DateTime now = DateTime.now();

    return <BookingHistory>[
      BookingHistory(
        id: 'bk-1',
        serviceName: 'Potong Rambut - Cukur Jenggot',
        storeName: 'Kemang Raya',
        date: now.add(const Duration(days: 2)),
        price: 95000,
        status: BookingStatus.progress,
      ),
      BookingHistory(
        id: 'bk-2',
        serviceName: 'Potong Rambut - Keramas',
        storeName: 'Kemang Raya',
        date: now.add(const Duration(days: 5)),
        price: 95000,
        status: BookingStatus.booked,
      ),
      BookingHistory(
        id: 'bk-3',
        serviceName: 'Potong Rambut - Cat Rambut',
        storeName: 'Pondok Indah',
        date: now.subtract(const Duration(days: 6)),
        price: 95000,
        status: BookingStatus.completed,
      ),
      BookingHistory(
        id: 'bk-4',
        serviceName: 'Potong Rambut - Hair Styling',
        storeName: 'Kemang Raya',
        date: now.subtract(const Duration(days: 12)),
        price: 100000,
        status: BookingStatus.completed,
        reviewScore: 4.8,
      ),
      BookingHistory(
        id: 'bk-5',
        serviceName: 'Potong Rambut - Hair Toner',
        storeName: 'Ciracas',
        date: now.subtract(const Duration(days: 20)),
        price: 95000,
        status: BookingStatus.canceled,
      ),
      BookingHistory(
        id: 'bk-6',
        serviceName: 'Potong Rambut - Cukur Jenggot',
        storeName: 'Pondok Gede',
        date: now.subtract(const Duration(days: 30)),
        price: 95000,
        status: BookingStatus.canceled,
      ),
    ];
  }

  Future<List<BookingHistory>> getHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<BookingHistory>.unmodifiable(_items);
  }

  Future<void> submitReview(String bookingId, ReviewDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    _items = _items
        .map(
          (BookingHistory item) => item.id == bookingId
              ? item.copyWith(reviewScore: draft.average)
              : item,
        )
        .toList(growable: false);
  }

  void resetDummy() {
    _items = _dummy();
    notifyListeners();
  }

  void clearDummy() {
    _items = const <BookingHistory>[];
    notifyListeners();
  }

  void useOnly(BookingStatus status) {
    _items = _dummy()
        .where((BookingHistory item) => item.status == status)
        .toList(growable: false);
    notifyListeners();
  }
}
