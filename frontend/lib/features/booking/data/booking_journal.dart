import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';

/// Sumber tunggal riwayat booking selama backend belum menyediakan daftarnya.
class BookingJournal extends ChangeNotifier {
  BookingJournal(this._cache) {
    _records = _read();
  }

  final AppCache _cache;

  List<BookingRecord> _records = const <BookingRecord>[];

  /// Terbaru di depan.
  List<BookingRecord> get records => _records;

  BookingRecord? get upcoming {
    final DateTime now = DateTime.now();

    final Iterable<BookingRecord> next = _records.where(
      (BookingRecord r) => !r.canceled && r.scheduledAt.isAfter(now),
    );
    if (next.isEmpty) return null;

    return next.reduce(
      (BookingRecord a, BookingRecord b) =>
          a.scheduledAt.isBefore(b.scheduledAt) ? a : b,
    );
  }

  List<BookingRecord> get past {
    final DateTime now = DateTime.now();

    return _records
        .where((BookingRecord r) => !r.canceled && !r.scheduledAt.isAfter(now))
        .toList(growable: false);
  }

  BookingRecord? byId(String id) {
    for (final BookingRecord r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> add(BookingRecord record) async {
    _records = <BookingRecord>[
      record,
      ..._records.where((BookingRecord r) => r.id != record.id),
    ];
    await _persist();
  }

  Future<void> setReview(String id, BookingReview review) async {
    _records = _records
        .map((BookingRecord r) => r.id == id ? r.copyWith(review: review) : r)
        .toList(growable: false);
    await _persist();
  }

  Future<void> cancel(String id) async {
    _records = _records
        .map((BookingRecord r) => r.id == id ? r.copyWith(canceled: true) : r)
        .toList(growable: false);
    await _persist();
  }

  Future<void> clear() async {
    _records = const <BookingRecord>[];
    await _persist();
  }

  List<BookingRecord> _read() {
    final List<Map<String, dynamic>> raw =
        _cache.readJson(AppCache.keyBookingJournal)?.asList ??
        const <Map<String, dynamic>>[];

    final List<BookingRecord> parsed = raw
        .map(BookingRecord.fromJson)
        .toList(growable: true);
    parsed.sort(
      (BookingRecord a, BookingRecord b) =>
          b.scheduledAt.compareTo(a.scheduledAt),
    );

    return List<BookingRecord>.unmodifiable(parsed);
  }

  Future<void> _persist() async {
    final List<BookingRecord> sorted = List<BookingRecord>.of(_records)
      ..sort(
        (BookingRecord a, BookingRecord b) =>
            b.scheduledAt.compareTo(a.scheduledAt),
      );
    _records = List<BookingRecord>.unmodifiable(sorted);

    notifyListeners();
    await _cache.writeJson(
      AppCache.keyBookingJournal,
      _records.map((BookingRecord r) => r.toJson()).toList(growable: false),
    );
  }
}
