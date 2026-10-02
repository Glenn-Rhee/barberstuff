import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';

// Catat pembayaran ke server dan buat struknya.
// Dialog, cetak, dan toast tetap di widget, di sini cuma urusan API
class CheckoutController {
  CheckoutController(this._bookingApi, this._shift, this._session);

  final BookingApi _bookingApi;
  final ShiftController _shift;
  final SessionController _session;

  // Pembayaran dicatat ke shift, jadi shift harus buka dulu
  bool get canTakePayment => _shift.isOpen;

  String get _cashierName => _session.profile?.name ?? '-';

  // Pesanan langsung: buat booking dulu, lalu catat pembayarannya
  Future<CheckoutResult> payWalkIn(
    OrderController order, {
    required Capster capster,
    required int cash,
  }) async {
    final lines = order.lines;
    final method = order.method;
    final customer = order.customerName;

    final String bookingId;
    try {
      bookingId = await _bookingApi.createBooking(
        storeId: _session.storeId,
        capsterId: capster.id,
        serviceIds: [
          for (final line in lines)
            for (var i = 0; i < line.qty; i++) line.item.id,
        ],
        bookingDate: DateTime.now(),
        customerName: order.nameController.text.trim(),
        customerPhone: order.customerPhone,
      );
    } on ApiException catch (e) {
      return CheckoutResult.failed('Gagal membuat pesanan: ${e.message}');
    }

    final error = await _shift.recordSale(
      amount: order.total,
      paymentType: method,
      title: 'Pesanan $customer',
      bookingId: bookingId,
    );
    if (error != null) {
      return CheckoutResult.failed(
        'Pesanan tersimpan, tapi pembayaran gagal dicatat: $error',
      );
    }

    return CheckoutResult.paid(
      Receipt(
        number: Receipt.numberFor(bookingId),
        createdAt: DateTime.now(),
        cashier: _cashierName,
        customer: customer,
        capster: capster.name,
        lines: lines,
        method: method,
        cash: cash,
      ),
    );
  }

  // Booking yang sudah ada: catat pembayaran pakai nominal dari server
  Future<CheckoutResult> payBooking(
    Booking booking, {
    required PaymentType method,
    required int cash,
  }) async {
    final error = await _shift.recordSale(
      amount: booking.total,
      paymentType: method,
      title: 'Booking ${booking.customer.name}',
      bookingId: booking.id,
    );
    if (error != null) return CheckoutResult.failed(error);

    return CheckoutResult.paid(
      receiptForBooking(booking, method: method, cash: cash),
    );
  }

  // Struk booking, [cash] null saat cetak ulang
  Receipt receiptForBooking(
    Booking booking, {
    required PaymentType method,
    required int? cash,
  }) {
    return Receipt(
      number: Receipt.numberFor(booking.id),
      createdAt: booking.scheduledAt ?? DateTime.now(),
      cashier: _cashierName,
      customer: booking.customer.name,
      capster: booking.capster.name,
      lines: booking.services,
      discount: booking.discount,
      method: method,
      cash: cash,
    );
  }
}

// Hasil bayar: struk untuk dicetak, atau alasan gagal
class CheckoutResult {
  const CheckoutResult.paid(Receipt this.receipt) : error = null;

  const CheckoutResult.failed(String this.error) : receipt = null;

  final Receipt? receipt;
  final String? error;
}
