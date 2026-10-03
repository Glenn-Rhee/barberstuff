import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/get_booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/submit_booking_review.dart';

/// Booking milik akun yang sedang login, dipakai bersama oleh beranda,
/// halaman riwayat, dan profil (dikosongkan saat logout).
class CustomerBookingsProvider extends ChangeNotifier {
  CustomerBookingsProvider(
    this._getHistory,
    this._submitReview, {
    Stream<BookingRecord>? createdBookings,
  }) {
    _created = createdBookings?.listen(_onBookingCreated);
  }

  final GetBookingHistory _getHistory;
  final SubmitBookingReview _submitReview;
  StreamSubscription<BookingRecord>? _created;

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
    final List<BookingRecord> records = await _getHistory(const NoParams());

    // Sudah logout selagi menunggu: jangan tampilkan data akun lama.
    if (generation != _generation) return;

    _records = List<BookingRecord>.unmodifiable(records);
    _loaded = true;
    notifyListeners();
  }

  Future<void> submitReview(String bookingId, ReviewDraft draft) async {
    final BookingRecord? record = byId(bookingId);
    if (record == null) throw const ApiException(ApiErrorType.unknown);

    await _submitReview(
      SubmitBookingReviewParams(booking: record, draft: draft),
    );

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
  void _onBookingCreated(BookingRecord _) {
    if (_loaded) refresh().ignore();
  }

  @override
  void dispose() {
    _created?.cancel();
    super.dispose();
  }
}
