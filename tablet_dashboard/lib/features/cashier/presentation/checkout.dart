import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/printer/bluetooth_printer.dart';
import '../../../core/printer/printer_controller.dart';
import '../../../core/printer/receipt_logo.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/api/barberstuff_api.dart';
import '../../../shared/models/person.dart';
import '../../../shared/widgets/common.dart';
import '../../auth/presentation/provider/session_controller.dart';
import '../../dashboard/domain/cash_session.dart';
import '../../dashboard/presentation/provider/shift_controller.dart';
import '../../reservation/domain/booking.dart';
import '../../reservation/presentation/provider/bookings_controller.dart';
import '../domain/receipt.dart';
import 'provider/order_controller.dart';
import 'widgets/payment_dialog.dart';

/// Rings up a walk-in order: creates the booking, records the payment on the
/// open cash session, then prints the receipt.
Future<void> checkoutWalkIn(BuildContext context, {required Capster capster}) async {
  final order = context.read<OrderController>();
  final shift = context.read<ShiftController>();
  final session = context.read<SessionController>();
  final api = context.read<BarberstuffApi>();

  if (!shift.isOpen) {
    AppToast.show(context, 'Buka shift kasir dulu di Dashboard', error: true);
    return;
  }

  final lines = order.lines;
  final total = order.total;
  final method = order.method;
  final customer = order.customerName;

  final cash = await showPaymentDialog(context, total: total, method: method);
  if (cash == null || !context.mounted) return;

  final String bookingId;
  try {
    bookingId = await api.createBooking(
      storeId: session.storeId,
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
    if (context.mounted) AppToast.show(context, 'Gagal membuat pesanan: ${e.message}', error: true);
    return;
  }

  if (!context.mounted) return;
  final error = await shift.recordSale(
    amount: total,
    paymentType: method,
    title: 'Pesanan $customer',
    bookingId: bookingId,
  );
  if (!context.mounted) return;
  if (error != null) {
    AppToast.show(context, 'Pesanan tersimpan, tapi pembayaran gagal dicatat: $error', error: true);
    return;
  }

  final receipt = Receipt(
    number: receiptNumber(bookingId),
    createdAt: DateTime.now(),
    cashier: session.profile?.name ?? '-',
    customer: customer,
    capster: capster.name,
    lines: lines,
    method: method,
    cash: cash,
  );
  await printWithRetry(context, receipt.toEscPos(logo: ReceiptLogo.cached));
  if (!context.mounted) return;

  order.clearAll();
  context.read<BookingsController>().refresh();
  AppToast.show(context, 'Pembayaran ${receipt.number} berhasil');
}

/// Takes payment for an existing booking and prints its receipt.
Future<void> checkoutBooking(BuildContext context, Booking booking, {required PaymentType method}) async {
  final shift = context.read<ShiftController>();

  if (!shift.isOpen) {
    AppToast.show(context, 'Buka shift kasir dulu di Dashboard', error: true);
    return;
  }

  final cash = await showPaymentDialog(context, total: booking.total, method: method);
  if (cash == null || !context.mounted) return;

  final error = await shift.recordSale(
    amount: booking.total,
    paymentType: method,
    title: 'Booking ${booking.customer.name}',
    bookingId: booking.id,
  );
  if (!context.mounted) return;
  if (error != null) {
    AppToast.show(context, error, error: true);
    return;
  }

  await printBookingReceipt(context, booking, method: method, cash: cash);
  if (!context.mounted) return;
  context.read<BookingsController>().refresh();
  AppToast.show(context, 'Pembayaran booking ${booking.customer.name} berhasil');
}

/// Prints (or reprints) the receipt of a booking using the server's amounts.
Future<bool> printBookingReceipt(
  BuildContext context,
  Booking booking, {
  required PaymentType method,
  required int? cash,
}) {
  final receipt = Receipt(
    number: receiptNumber(booking.id),
    createdAt: booking.scheduledAt ?? DateTime.now(),
    cashier: context.read<SessionController>().profile?.name ?? '-',
    customer: booking.customer.name,
    capster: booking.capster.name,
    lines: booking.services,
    discount: booking.discount,
    method: method,
    cash: cash,
  );
  return printWithRetry(context, receipt.toEscPos(logo: ReceiptLogo.cached));
}

/// Booking ids are UUIDs; the receipt shows a short, readable form.
String receiptNumber(String bookingId) {
  final head = bookingId.replaceAll('-', '');
  return 'BK-${(head.length >= 8 ? head.substring(0, 8) : head).toUpperCase()}';
}

/// Prints [bytes]; when it fails the cashier can retry or skip. Returns `true` when printed.
Future<bool> printWithRetry(BuildContext context, Uint8List bytes) async {
  while (true) {
    if (!context.mounted) return false;
    final error = await _printOnce(context, bytes);
    if (error == null) return true;
    if (!context.mounted) return false;

    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Struk gagal dicetak', style: AppTextStyle.sectionTitle),
        content: Text('$error\n\nCek printer di menu Konfigurasi.', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Lewati')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Coba Lagi')),
        ],
      ),
    );
    if (retry != true) return false;
  }
}

/// Sends [bytes] behind a "Mencetak…" overlay; returns the error message, or `null` on success.
Future<String?> _printOnce(BuildContext context, Uint8List bytes) async {
  final printer = context.read<PrinterController>();
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _PrintingDialog());
  try {
    await printer.printBytes(bytes);
    return null;
  } on PrinterException catch (e) {
    return e.message;
  } finally {
    navigator.pop();
  }
}

class _PrintingDialog extends StatelessWidget {
  const _PrintingDialog();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            SizedBox(width: 16),
            Text('Mencetak struk…', style: AppTextStyle.bodyStrong),
          ],
        ),
      ),
    );
  }
}
