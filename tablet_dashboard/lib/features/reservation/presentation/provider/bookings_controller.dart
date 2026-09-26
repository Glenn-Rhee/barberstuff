import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../data/api/barberstuff_api.dart';
import '../../domain/booking.dart';

/// Bookings of the store (`GET /booking`), filtered and paged server side.
class BookingsController extends ChangeNotifier {
  BookingsController(this._api);

  static const pageSize = 5;

  final BarberstuffApi _api;

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

  Booking? get selected => bookings.where((b) => b.id == selectedId).firstOrNull;

  /// Bookings that still need the cashier's attention, soonest first.
  List<Booking> get upcoming => [
    for (final booking in bookings)
      if (!booking.status.isFinal) booking,
  ]..sort((a, b) => (a.scheduledAt ?? DateTime(0)).compareTo(b.scheduledAt ?? DateTime(0)));

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

  /// Tapping the selected row again collapses it.
  void toggle(Booking booking) {
    selectedId = selectedId == booking.id ? null : booking.id;
    notifyListeners();
  }

  /// Used after scanning a QR code so the booking is selected when it loads.
  Future<void> focusById(String id) async {
    query = id;
    status = null;
    page = 1;
    await refresh();
    selectedId = bookings.where((b) => b.id == id).firstOrNull?.id ?? bookings.firstOrNull?.id;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
