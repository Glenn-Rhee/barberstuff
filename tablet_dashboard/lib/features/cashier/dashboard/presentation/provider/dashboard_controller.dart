import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';

// Ringkasan reservasi hari ini untuk dashboard, terpisah dari tabel
// reservasi di Kasir supaya filter di sana tidak ikut mengubah dashboard
class DashboardController extends ChangeNotifier {
  DashboardController(this._api);

  // Batas maksimal limit dari backend
  static const _maxLimit = 50;

  // Maks 200 booking per hari, cukup untuk satu toko
  static const _maxPages = 4;

  final BookingApi _api;

  List<Booking> today = const [];
  int totalToday = 0;

  // Status booked = pelanggan belum datang / belum check-in
  int waiting = 0;

  bool loading = false;
  String? error;

  // Balasan request lama diabaikan
  int _request = 0;

  // Booking yang belum selesai, urut dari jadwal terdekat
  List<Booking> get upcoming =>
      [
        for (final booking in today)
          if (!booking.status.isFinal) booking,
      ]..sort(
        (a, b) => (a.scheduledAt ?? DateTime(0)).compareTo(
          b.scheduledAt ?? DateTime(0),
        ),
      );

  // [silent] = muat ulang di belakang layar: data lama tetap tampil tanpa
  // kerangka loading, dan kalau gagal data lama tidak dihapus
  Future<void> refresh({bool silent = false}) async {
    final request = ++_request;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      // GET /booking sudah otomatis booking hari ini di toko akun.
      // Jumlah dihitung dari list, karena meta.total_data backend salah
      final all = <Booking>[];
      for (var page = 1; page <= _maxPages; page++) {
        final result = await _api.bookings(page: page, limit: _maxLimit);
        all.addAll(result.items);
        if (result.items.length < _maxLimit) break;
      }
      if (request != _request) return;
      today = all;
      totalToday = all.length;
      waiting = all.where((b) => b.status == BookingStatus.booked).length;
      error = null;
    } on ApiException catch (e) {
      if (request != _request || silent) return;
      error = e.message;
      today = const [];
    } finally {
      if (request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }
}
