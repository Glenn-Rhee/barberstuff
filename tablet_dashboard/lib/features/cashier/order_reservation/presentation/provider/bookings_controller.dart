import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';

// Booking toko (GET /booking), filter dan halaman diproses di server
class BookingsController extends ChangeNotifier {
  BookingsController(this._api);

  static const pageSize = 5;

  // QR aplikasi = "bk" + 4 karakter awal id, kasir = "bk" + id penuh
  static const _shortQrLength = 4;
  static const _qrNotFound = 'Booking tidak ditemukan.';

  final BookingApi _api;

  BookingStatus? status;
  String query = '';

  // null = hari ini, otomatis ganti hari lewat tengah malam
  DateTime? date;
  int page = 1;
  int totalPages = 1;
  int totalData = 0;

  List<Booking> bookings = const [];
  bool loading = false;
  String? error;
  String? selectedId;

  Timer? _debounce;

  // Nomor request terakhir, balasan request lama diabaikan
  int _request = 0;

  Booking? get selected =>
      bookings.where((b) => b.id == selectedId).firstOrNull;

  DateTime get day => date ?? DateTime.now();
  bool get isToday => date == null;

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

  // [silent] = muat ulang diam-diam, kalau gagal data lama tetap
  Future<void> refresh({bool silent = false}) async {
    final request = ++_request;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final result = await _api.bookings(
        status: status,
        query: query.trim().isEmpty ? null : query.trim(),
        date: date,
        page: page,
        limit: pageSize,
      );
      if (request != _request) return;
      bookings = result.items;
      totalPages = result.totalPages == 0 ? 1 : result.totalPages;
      totalData = result.totalData;
      error = null;
      if (selected == null) selectedId = null;
    } on ApiException catch (e) {
      if (request != _request || silent) return;
      error = e.message;
      bookings = const [];
    } finally {
      if (request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void setStatus(BookingStatus? value) {
    status = value;
    page = 1;
    refresh();
  }

  // Pilih hari ini = kembali ke null
  void setDate(DateTime value) {
    date = _dayOf(value);
    page = 1;
    refresh();
  }

  static DateTime? _dayOf(DateTime? value) =>
      value == null || DateFormatId.isSameDay(value, DateTime.now())
      ? null
      : DateTime(value.year, value.month, value.day);

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

  // Check-in pakai QR id penuh, tidak ketemu = QR pendek
  Future<String?> checkInBooking(Booking booking) async {
    final error = await checkIn('bk${booking.id}');
    if (error != _qrNotFound || booking.id.length <= _shortQrLength) {
      return error;
    }
    return checkIn('bk${booking.id.substring(0, _shortQrLength)}');
  }

  // Tambah layanan ke booking. Balikin error, null = berhasil
  Future<String?> addService(Booking booking, String serviceId) => _changeItems(
    () => _api.addService(bookingId: booking.id, serviceId: serviceId),
  );

  // Keluarkan item, backend menolak booking kosong
  Future<String?> removeService(Booking booking, String serviceId) =>
      _changeItems(
        () => _api.removeService(bookingId: booking.id, serviceId: serviceId),
      );

  Future<String?> _changeItems(Future<void> Function() request) async {
    String? error;
    try {
      await request();
    } on ApiException catch (e) {
      error = e.message;
    }
    await refresh();
    return error;
  }

  // Tap baris yang sama lagi = tutup detail
  void toggle(Booking booking) {
    selectedId = selectedId == booking.id ? null : booking.id;
    notifyListeners();
  }

  // Setelah check-in: buang filter, muat ulang, pilih booking itu.
  // QR aplikasi cuma awal id, jadi cocokkan awalannya. [day] null = hari ini
  Future<void> focus(String bookingId, {DateTime? day}) async {
    status = null;
    query = '';
    date = _dayOf(day);
    page = 1;
    await refresh();
    final match =
        bookings.where((b) => b.id == bookingId).firstOrNull ??
        bookings
            .where(
              (b) =>
                  b.id.startsWith(bookingId) &&
                  b.status == BookingStatus.progress,
            )
            .firstOrNull;
    if (match != null) selectedId = match.id;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
