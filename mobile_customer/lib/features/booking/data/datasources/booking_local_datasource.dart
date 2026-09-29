import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_record_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';

/// Data booking yang hanya ada di perangkat:
/// - jurnal booking yang dibuat dari perangkat ini, karena daftar booking dari
///   server tidak mengirim kode QR dan biaya layanan;
/// - progres booking (persetujuan syarat dan slot yang sedang dikunci).
class BookingLocalDataSource {
  BookingLocalDataSource(this._cache) {
    _records = _read();
  }

  final AppCache _cache;

  List<BookingRecord> _records = const <BookingRecord>[];

  /// Terbaru di depan.
  List<BookingRecord> get records => _records;

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

  bool readTermsAgreed() => _cache.readBool(AppCache.keyBookingTermsAgreed);

  Future<void> writeTermsAgreed(bool value) =>
      _cache.writeJson(AppCache.keyBookingTermsAgreed, value);

  Map<String, dynamic>? readLock() =>
      _cache.readJson(AppCache.keyBookingLock)?.asMap;

  Future<void> writeLock(Map<String, dynamic> json) =>
      _cache.writeJson(AppCache.keyBookingLock, json);

  Future<void> clearLock() => _cache.remove(AppCache.keyBookingLock);

  List<BookingRecord> _read() {
    final List<Map<String, dynamic>> raw =
        _cache.readJson(AppCache.keyBookingJournal)?.asList ??
        const <Map<String, dynamic>>[];

    final List<BookingRecord> parsed = raw
        .map(BookingRecordModel.fromJson)
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

    await _cache.writeJson(
      AppCache.keyBookingJournal,
      _records
          .map((BookingRecord r) => BookingRecordModel.fromEntity(r).toJson())
          .toList(growable: false),
    );
  }
}
