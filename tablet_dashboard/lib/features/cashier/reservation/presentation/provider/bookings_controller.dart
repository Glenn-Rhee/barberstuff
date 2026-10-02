import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';

// Booking toko (GET /booking), filter dan halaman diproses di server
class BookingsController extends ChangeNotifier {
  BookingsController(this._api);

  static const pageSize = 5;

  final BookingApi _api;

  BookingStatus? status;
  String query = '';
  int page = 1;
  int totalPages = 1;
  int totalData = 0;

  List<Booking> bookings = const [];
  bool loading = false;
  String? error;
  String? selectedId;

  Timer? _debounce;

  Booking? get selected =>
      bookings.where((b) => b.id == selectedId).firstOrNull;

  // Booking yang belum selesai, urut dari jadwal terdekat
  List<Booking> get upcoming =>
      [
        for (final booking in bookings)
          if (!booking.status.isFinal) booking,
      ]..sort(
        (a, b) => (a.scheduledAt ?? DateTime(0)).compareTo(
          b.scheduledAt ?? DateTime(0),
        ),
      );

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _api.bookings(
        status: status,
        query: query.trim().isEmpty ? null : query.trim(),
        page: page,
        limit: pageSize,
      );
      bookings = result.items;
      totalPages = result.totalPages == 0 ? 1 : result.totalPages;
      totalData = result.totalData;
      if (selected == null) selectedId = null;
    } on ApiException catch (e) {
      error = e.message;
      bookings = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setStatus(BookingStatus? value) {
    status = value;
    page = 1;
    refresh();
  }

  void setQuery(String value) {
    query = value;
    page = 1;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), refresh);
    notifyListeners();
  }

  void setPage(int value) {
    page = value.clamp(1, totalPages);
    refresh();
  }

  // Check-in pakai kode QR. Balikin pesan error, atau null kalau berhasil
  Future<String?> checkIn(String qrCode) async {
    try {
      await _api.checkIn(qrCode);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  // Tambah layanan ke [booking] lalu muat ulang list.
  // Balikin pesan error, atau null kalau berhasil
  Future<String?> addService(Booking booking, String serviceId) async {
    try {
      await _api.addService(bookingId: booking.id, serviceId: serviceId);
    } on ApiException catch (e) {
      return e.message;
    }
    await refresh();
    return null;
  }

  // Tap baris yang sama lagi = tutup detail
  void toggle(Booking booking) {
    selectedId = selectedId == booking.id ? null : booking.id;
    notifyListeners();
  }

  // Setelah scan QR: buang filter, muat ulang, lalu pilih booking itu
  Future<void> focus(String bookingId) async {
    status = null;
    query = '';
    page = 1;
    await refresh();
    if (bookings.any((b) => b.id == bookingId)) selectedId = bookingId;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
