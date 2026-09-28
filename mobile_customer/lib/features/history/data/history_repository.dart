import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/history/data/history_remote_datasource.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

/// Riwayat booking akun yang sedang login, dari `GET /booking/customer`.
///
/// Dulu riwayat dibaca dari jurnal perangkat, akibatnya akun baru di HP yang
/// sama ikut melihat booking akun sebelumnya. Sekarang server sumbernya,
/// jurnal cuma melengkapi kode QR dan biaya layanan untuk booking yang dibuat
/// dari perangkat ini (dicocokkan lewat id booking).
class HistoryRepository extends ChangeNotifier {
  HistoryRepository(this._remote, this._journal) {
    _journal.addListener(_onJournalChanged);
  }

  final HistoryRemoteDataSource _remote;
  final BookingJournal _journal;

  List<BookingRecord> _records = const <BookingRecord>[];
  bool _loaded = false;

  /// Naik setiap [reset], supaya respons milik sesi lama dibuang.
  int _generation = 0;
  Future<void>? _inFlight;

  /// Terbaru di depan.
  List<BookingRecord> get records => _records;
  bool get isLoaded => _loaded;

  /// Booking akan datang yang jadwalnya paling dekat.
  BookingRecord? get upcoming {
    final Iterable<BookingRecord> next = _records.where(
      (BookingRecord r) =>
          r.status == BookingStatus.booked ||
          r.status == BookingStatus.progress,
    );
    if (next.isEmpty) return null;

    return next.reduce(
      (BookingRecord a, BookingRecord b) =>
          a.scheduledAt.isBefore(b.scheduledAt) ? a : b,
    );
  }

  List<BookingRecord> get completed => _records
      .where((BookingRecord r) => r.status == BookingStatus.completed)
      .toList(growable: false);

  BookingRecord? byId(String id) {
    for (final BookingRecord r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Pemanggil yang datang saat masih memuat ikut menunggu muatan yang sama.
  Future<void> refresh() {
    final Future<void>? running = _inFlight;
    if (running != null) return running;

    late final Future<void> run;
    run = _fetch().whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    return _inFlight = run;
  }

  Future<void> _fetch() async {
    final int generation = _generation;

    final List<List<Map<String, dynamic>>> pages;
    try {
      pages = await Future.wait(<Future<List<Map<String, dynamic>>>>[
        for (final HistoryTab tab in HistoryTab.values) _remote.getBookings(tab),
      ]);
    } catch (e) {
      throw DioClient.mapError(e);
    }

    // Sudah logout selagi menunggu: jangan tampilkan data akun lama.
    if (generation != _generation) return;

    final List<BookingRecord> merged = <BookingRecord>[
      for (int i = 0; i < HistoryTab.values.length; i++)
        for (final Map<String, dynamic> json in pages[i])
          BookingRecord.fromServer(
            json,
            status: _statusOf(HistoryTab.values[i]),
            local: _journal.byId('${json['id'] ?? ''}'),
          ),
    ]..sort(
        (BookingRecord a, BookingRecord b) =>
            b.scheduledAt.compareTo(a.scheduledAt),
      );

    _records = List<BookingRecord>.unmodifiable(merged);
    _loaded = true;
    notifyListeners();
  }

  Future<void> submitReview(String bookingId, ReviewDraft draft) async {
    final BookingRecord? record = byId(bookingId);
    if (record == null) throw const ApiException(ApiErrorType.unknown);

    try {
      await _remote.createRating(
        draft.toRatingBody(
          bookingId: record.id,
          capsterId: record.capsterId,
          staffId: record.staffId,
          storeId: record.storeId,
        ),
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }

    final BookingReview review = BookingReview(
      capster: draft.capster,
      cashier: draft.cashier,
      store: draft.store,
      message: draft.message.trim(),
    );
    _records = List<BookingRecord>.unmodifiable(
      _records.map(
        (BookingRecord r) => r.id == bookingId ? r.copyWith(review: review) : r,
      ),
    );
    notifyListeners();
  }

  /// Ulasan tersimpan, dipakai untuk membuka sheet dalam mode baca.
  ReviewDraft? reviewOf(String bookingId) {
    final BookingReview? review = byId(bookingId)?.review;
    if (review == null) return null;

    return ReviewDraft(
      capster: review.capster,
      cashier: review.cashier,
      store: review.store,
      message: review.message,
    );
  }

  /// Dipanggil saat logout supaya akun berikutnya tidak melihat data lama.
  void reset() {
    _generation++;
    _inFlight = null;
    _records = const <BookingRecord>[];
    _loaded = false;
    notifyListeners();
  }

  /// Booking baru dari perangkat ini: ambil ulang supaya langsung muncul.
  void _onJournalChanged() {
    if (_loaded) refresh().ignore();
  }

  static BookingStatus _statusOf(HistoryTab tab) {
    switch (tab) {
      case HistoryTab.upcoming:
        return BookingStatus.booked;
      case HistoryTab.done:
        return BookingStatus.completed;
      case HistoryTab.canceled:
        return BookingStatus.canceled;
    }
  }

  @override
  void dispose() {
    _journal.removeListener(_onJournalChanged);
    super.dispose();
  }
}
