import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/data/datasources/history_remote_datasource.dart';
import 'package:mobile_barberstuff/features/history/data/models/customer_booking_model.dart';
import 'package:mobile_barberstuff/features/history/data/models/review_draft_model.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/repositories/history_repository.dart';

/// Riwayat booking akun yang sedang login, dari `GET /booking/customer`.
///
/// Dulu riwayat dibaca dari jurnal perangkat, akibatnya akun baru di HP yang
/// sama ikut melihat booking akun sebelumnya. Sekarang server sumbernya,
/// jurnal cuma melengkapi kode QR dan biaya layanan untuk booking yang dibuat
/// dari perangkat ini (dicocokkan lewat id booking).
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._remote, this._journal);

  final HistoryRemoteDataSource _remote;
  final BookingLocalDataSource _journal;

  @override
  Future<List<BookingRecord>> getBookings() async {
    final List<List<Map<String, dynamic>>> pages;
    try {
      pages = await Future.wait(<Future<List<Map<String, dynamic>>>>[
        for (final HistoryTab tab in HistoryTab.values)
          _remote.getBookings(tab),
      ]);
    } catch (e) {
      throw DioClient.mapError(e);
    }

    return <BookingRecord>[
      for (int i = 0; i < HistoryTab.values.length; i++)
        for (final Map<String, dynamic> json in pages[i])
          CustomerBookingModel.fromJson(
            json,
            status: _statusOf(HistoryTab.values[i]),
            local: _journal.byId('${json['id'] ?? ''}'),
          ),
    ]..sort(
      (BookingRecord a, BookingRecord b) =>
          b.scheduledAt.compareTo(a.scheduledAt),
    );
  }

  @override
  Future<void> submitReview(BookingRecord booking, ReviewDraft draft) async {
    try {
      await _remote.createRating(
        draft.toRatingBody(
          bookingId: booking.id,
          capsterId: booking.capsterId,
          staffId: booking.staffId,
          storeId: booking.storeId,
        ),
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
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
}
