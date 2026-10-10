import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
<<<<<<< HEAD
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
=======
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
import 'package:tablet_dashboard/features/cashier/order/domain/entities/discount.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';

<<<<<<< HEAD
// Catat pesanan & pembayaran ke server dan buat struknya.
// Dialog, cetak, dan toast tetap di widget, di sini cuma urusan API
class CheckoutController {
  CheckoutController(this._bookingApi, this._shift, this._session, this._store);
=======
// Catat pesanan & bayar ke server lalu buat struk (UI tetap di widget)
class CheckoutController {
  CheckoutController(
    this._bookingApi,
    this._shift,
    this._session,
    this._store,
    this._clock,
  );
>>>>>>> 7d13d7e32679190728e118598f013051b3289112

  // Cari booking baru maks 4 halaman x 50
  static const _searchLimit = 50;
  static const _searchPages = 4;

  final BookingApi _bookingApi;
  final ShiftController _shift;
  final SessionController _session;

  // Toko yang dipakai (admin bisa ganti cabang)
  final StoreController _store;

<<<<<<< HEAD
=======
  // Jam server, jam tablet bisa salah
  final ServerClock _clock;

>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  // Pembayaran dicatat ke shift, jadi shift harus buka dulu
  bool get canTakePayment => _shift.isOpen;

  String get _cashierName => _session.profile?.name ?? '-';

<<<<<<< HEAD
  // Pesanan langsung dibuat sebagai booking jam sekarang, karena backend tidak
  // mengembalikan id booking walk-in. Booking dicari lagi di GET /booking,
  // lalu langsung check-in (status progress) supaya tidak kena auto-cancel.
  // Hasilnya muncul di tab Dari Reservasi dan siap dibayar
=======
  // Walk-in dibuat sebagai booking (backend tidak balikin id), dicari lagi,
  // lalu langsung check-in supaya tidak kena auto-cancel
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Future<WalkInResult> startWalkIn(
    OrderController order, {
    required Capster capster,
  }) async {
    final customer = order.customer;
    final phone = order.customerPhone;
    final serviceIds = [for (final item in order.items) item.id];
    try {
      await _bookingApi.createBooking(
        storeId: _store.storeId,
        capsterId: capster.id,
        serviceIds: serviceIds,
<<<<<<< HEAD
        // +1 menit supaya tidak dianggap jam lewat oleh server
        bookingDate: DateTime.now().add(const Duration(minutes: 1)),
=======
        // Jam server +1 menit, jam tablet bisa salah
        bookingDate: _clock.now().add(const Duration(minutes: 1)),
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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
<<<<<<< HEAD
    } on ApiException catch (e) {
      return WalkInResult.failed(
        'Pesanan tersimpan, tapi gagal dimuat ulang: ${e.message}. '
        'Cek di tab Dari Reservasi.',
=======
    } on ApiException {
      return const WalkInResult.failed(
        'Pesanan tersimpan, cek di tab Dari Reservasi.',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
        created: true,
      );
    }
    if (booking == null) {
      return const WalkInResult.failed(
<<<<<<< HEAD
        'Pesanan tersimpan, tapi tidak ketemu di daftar. Cek di tab Dari Reservasi.',
=======
        'Pesanan tersimpan, cek di tab Dari Reservasi.',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
        created: true,
      );
    }

    try {
      await _bookingApi.checkIn('bk${booking.id}');
    } on ApiException catch (e) {
      return WalkInResult.failed(
<<<<<<< HEAD
        'Pesanan tersimpan tapi belum check-in: ${e.message}. Check-in dari '
        'tab Dari Reservasi dalam 10 menit, setelah itu dibatalkan otomatis.',
=======
        'Belum check-in, ulangi di Dari Reservasi dalam 10 menit. ${e.message}',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
        created: true,
      );
    }
    return WalkInResult.started(booking);
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
<<<<<<< HEAD
        'Pesanan tersimpan di Dari Reservasi, tapi pembayaran gagal dicatat: $error',
=======
        'Pembayaran gagal, ulangi di Dari Reservasi. $error',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
        created: true,
      );
    }

    return CheckoutResult.paid(
      Receipt(
        number: Receipt.numberFor(booking.id),
<<<<<<< HEAD
        createdAt: DateTime.now(),
=======
        createdAt: _clock.now(),
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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

<<<<<<< HEAD
  // Booking yang sudah ada: catat pembayaran pakai nominal dari server,
  // dikurangi [discount] kasir (hanya bisa saat status progress)
=======
  // Bayar booking: total server dikurangi [discount] (hanya saat progress)
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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

<<<<<<< HEAD
  // Struk booking, [cash] null saat cetak ulang.
  // [discount] = diskon kasir yang baru dibayar, belum ada di data booking
=======
  // Struk booking. [cash] null = cetak ulang, [discount] = diskon baru dibayar
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Receipt receiptForBooking(
    Booking booking, {
    required PaymentType method,
    required int? cash,
    int discount = 0,
  }) {
    return Receipt(
      number: Receipt.numberFor(booking.id),
      createdAt: booking.scheduledAt ?? DateTime.now(),
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

<<<<<<< HEAD
// Hasil pesanan langsung: booking yang sudah check-in, atau alasan gagal.
// [created] true = pesanan sudah terlanjur dibuat di server
=======
// Hasil walk-in. [created] = pesanan sudah terbuat di server
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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

<<<<<<< HEAD
// Hasil bayar: struk untuk dicetak, atau alasan gagal.
// [created] true = pesanan sudah ada di server walau bayar gagal
=======
// Hasil bayar. [created] = pesanan ada di server walau bayar gagal
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
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
