import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/discount.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';

// Catat pesanan & bayar ke server lalu buat struk (UI tetap di widget)
class CheckoutController {
  CheckoutController(
    this._bookingApi,
    this._shift,
    this._session,
    this._store,
    this._clock,
  );

  // Cari booking baru maks 4 halaman x 50
  static const _searchLimit = 50;
  static const _searchPages = 4;

  final BookingApi _bookingApi;
  final ShiftController _shift;
  final SessionController _session;

  // Toko yang dipakai (admin bisa ganti cabang)
  final StoreController _store;

  // Jam server, jam tablet bisa salah
  final ServerClock _clock;

  // Pembayaran dicatat ke shift, jadi shift harus buka dulu
  bool get canTakePayment => _shift.isOpen;

  String get _cashierName => _session.profile?.name ?? '-';

  // Walk-in dibuat sebagai booking (backend tidak balikin id), dicari lagi,
  // lalu langsung check-in supaya tidak kena auto-cancel
  Future<WalkInResult> startWalkIn(
    OrderController order, {
    required Capster capster,
  }) async {
    final customer = order.customer;
    final phone = order.customerPhone;
    final lines = order.lines;
    // Dibuat 1x per layanan, sisa jumlahnya ditambah setelah check-in
    final serviceIds = [for (final line in lines) line.item.id];
    try {
      await _bookingApi.createBooking(
        storeId: _store.storeId,
        capsterId: capster.id,
        serviceIds: serviceIds,
        // Jam server +1 menit, jam tablet bisa salah
        bookingDate: _clock.now().add(const Duration(minutes: 1)),
        customerId: customer?.id,
        customerName: customer == null
            ? order.nameController.text.trim()
            : null,
        customerPhone: customer == null ? phone : null,
        scheduled: true,
      );
    } on ApiException catch (e) {
      return WalkInResult.failed('Gagal membuat pesanan: ${e.message}');
    }

    final Booking? booking;
    try {
      booking = await _findNewBooking(
        capsterId: capster.id,
        customerId: customer?.id,
        phone: phone,
        serviceIds: serviceIds,
      );
    } on ApiException {
      return const WalkInResult.failed(
        'Pesanan tersimpan, cek di tab Dari Reservasi.',
        created: true,
      );
    }
    if (booking == null) {
      return const WalkInResult.failed(
        'Pesanan tersimpan, cek di tab Dari Reservasi.',
        created: true,
      );
    }

    try {
      await _bookingApi.checkIn('bk${booking.id}');
    } on ApiException catch (e) {
      return WalkInResult.failed(
        'Belum check-in, ulangi di Dari Reservasi dalam 10 menit. ${e.message}',
        created: true,
      );
    }

    if (lines.every((line) => line.qty == 1)) {
      return WalkInResult.started(booking);
    }
    return _addExtraQty(booking.id, lines);
  }

  // Jumlah > 1: tambah lewat POST /staff/booking/item (1 item per request,
  // hanya saat progress), lalu baca lagi booking-nya supaya total ikut server
  Future<WalkInResult> _addExtraQty(
    String bookingId,
    List<CartLine> lines,
  ) async {
    for (final line in lines) {
      for (var i = 1; i < line.qty; i++) {
        try {
          await _bookingApi.addService(
            bookingId: bookingId,
            serviceId: line.item.id,
          );
        } on ApiException catch (e) {
          return WalkInResult.failed(
            'Pesanan tersimpan, tapi ${line.item.name} x${line.qty} gagal: '
            '${e.message} Cek di tab Dari Reservasi.',
            created: true,
          );
        }
      }
    }

    final Booking? booking;
    try {
      booking = await _findProgress(bookingId);
    } on ApiException {
      return const WalkInResult.failed(
        'Pesanan tersimpan, bayar dari tab Dari Reservasi.',
        created: true,
      );
    }
    if (booking == null) {
      return const WalkInResult.failed(
        'Pesanan tersimpan, bayar dari tab Dari Reservasi.',
        created: true,
      );
    }

    // Server bisa balas sukses tapi jumlahnya tidak bertambah
    final wrong = [
      for (final line in lines)
        if (booking.qtyOf(line.item.id) != line.qty)
          '${line.item.name} x${booking.qtyOf(line.item.id)}',
    ];
    if (wrong.isNotEmpty) {
      return WalkInResult.failed(
        'Pesanan tersimpan, tapi di server ${wrong.join(', ')}. '
        'Cek di tab Dari Reservasi.',
        created: true,
      );
    }
    return WalkInResult.started(booking);
  }

  // Booking progress dengan [id] (pesanan hari ini)
  Future<Booking?> _findProgress(String id) async {
    for (var page = 1; page <= _searchPages; page++) {
      final result = await _bookingApi.bookings(
        status: BookingStatus.progress,
        page: page,
        limit: _searchLimit,
      );
      final match = result.items.where((b) => b.id == id).firstOrNull;
      if (match != null) return match;
      if (result.items.length < _searchLimit) break;
    }
    return null;
  }

  // Booking "booked" terbaru dengan capster, pelanggan, dan layanan yang sama
  Future<Booking?> _findNewBooking({
    required String capsterId,
    required String? customerId,
    required String phone,
    required List<String> serviceIds,
  }) async {
    final phoneDigits = CustomerHistoryController.digitsOf(phone);
    final wanted = serviceIds.toSet();
    final found = <Booking>[];
    for (var page = 1; page <= _searchPages; page++) {
      final result = await _bookingApi.bookings(
        status: BookingStatus.booked,
        page: page,
        limit: _searchLimit,
      );
      found.addAll(
        result.items.where((b) {
          final sameCustomer = customerId != null
              ? b.customer.id == customerId
              : CustomerHistoryController.digitsOf(b.customer.phone ?? '') ==
                    phoneDigits;
          final services = {for (final line in b.services) line.item.id};
          return b.capster.id == capsterId &&
              sameCustomer &&
              services.containsAll(wanted);
        }),
      );
      if (result.items.length < _searchLimit) break;
    }
    found.sort(
      (a, b) => (b.scheduledAt ?? DateTime(0)).compareTo(
        a.scheduledAt ?? DateTime(0),
      ),
    );
    return found.firstOrNull;
  }

  // Bayar pesanan langsung: buat + check-in, lalu catat pembayaran
  Future<CheckoutResult> payWalkIn(
    OrderController order, {
    required Capster capster,
    required int cash,
  }) async {
    final lines = order.lines;
    final method = order.method;
    final customer = order.customerName;
    final discount = order.discount;

    final started = await startWalkIn(order, capster: capster);
    final booking = started.booking;
    if (booking == null) {
      return CheckoutResult.failed(started.error!, created: started.created);
    }

    // Diskon dihitung dari total server, backend tolak kalau melebihi total
    final discountAmount = discount?.amountFor(booking.total) ?? 0;
    final error = await _shift.recordSale(
      amount: booking.total - discountAmount,
      discountAmount: discountAmount,
      paymentType: method,
      title: 'Pesanan $customer',
      bookingId: booking.id,
    );
    if (error != null) {
      return CheckoutResult.failed(
        'Pembayaran gagal, ulangi di Dari Reservasi. $error',
        created: true,
      );
    }

    return CheckoutResult.paid(
      Receipt(
        number: Receipt.numberFor(booking.id),
        createdAt: _clock.now(),
        cashier: _cashierName,
        customer: customer,
        capster: capster.name,
        lines: lines,
        discount: discountAmount,
        method: method,
        cash: cash,
      ),
    );
  }

  // Bayar booking: total server dikurangi [discount] (hanya saat progress)
  Future<CheckoutResult> payBooking(
    Booking booking, {
    required PaymentType method,
    required int cash,
    Discount? discount,
  }) async {
    final discountAmount = discount?.amountFor(booking.total) ?? 0;
    final error = await _shift.recordSale(
      amount: booking.total - discountAmount,
      discountAmount: discountAmount,
      paymentType: method,
      title: 'Booking ${booking.customer.name}',
      bookingId: booking.id,
    );
    if (error != null) return CheckoutResult.failed(error);

    return CheckoutResult.paid(
      receiptForBooking(
        booking,
        method: method,
        cash: cash,
        discount: discountAmount,
      ),
    );
  }

  // Struk booking. [cash] null = cetak ulang, [discount] = diskon baru dibayar
  Receipt receiptForBooking(
    Booking booking, {
    required PaymentType method,
    required int? cash,
    int discount = 0,
  }) {
    return Receipt(
      number: Receipt.numberFor(booking.id),
      createdAt: booking.scheduledAt ?? _clock.now(),
      cashier: _cashierName,
      customer: booking.customer.name,
      capster: booking.capster.name,
      lines: booking.services,
      discount: booking.totalDiscount + discount,
      method: method,
      cash: cash,
    );
  }
}

// Hasil walk-in. [created] = pesanan sudah terbuat di server
class WalkInResult {
  const WalkInResult.started(Booking this.booking)
    : error = null,
      created = true;

  const WalkInResult.failed(String this.error, {this.created = false})
    : booking = null;

  final Booking? booking;
  final String? error;
  final bool created;
}

// Hasil bayar. [created] = pesanan ada di server walau bayar gagal
class CheckoutResult {
  const CheckoutResult.paid(Receipt this.receipt)
    : error = null,
      created = true;

  const CheckoutResult.failed(String this.error, {this.created = false})
    : receipt = null;

  final Receipt? receipt;
  final String? error;
  final bool created;
}
