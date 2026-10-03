import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/payment_dialog.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/service_picker_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/display/summary_row.dart';
import 'package:tablet_dashboard/shared/widgets/display/total_row.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Keranjang & aksi booking yang dipilih, nominal dari server.
// Booked = check-in, Progress = tambah layanan & bayar,
// Completed = cetak struk, Cancel = kosong
class BookingPanel extends StatefulWidget {
  const BookingPanel({super.key});

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel> {
  PaymentType _method = PaymentType.cash;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Booked -> Progress lewat check-in, QR booking = "bk{id}"
  Future<void> _checkIn(Booking booking) => _run(() async {
    final bookings = context.read<BookingsController>();
    final error = await bookings.checkIn('bk${booking.id}');
    if (!mounted) return;
    if (error == null) await bookings.focus(booking.id);
    if (!mounted) return;
    AppToast.show(
      context,
      error ?? '${booking.customer.name} sudah check-in',
      error: error != null,
    );
  });

  // Aturan: 1 pelanggan cuma 1 layanan / paket, jadi isi booking diganti
  Future<void> _replaceService(Booking booking) async {
    final bookings = context.read<BookingsController>();
    final item = await showServicePicker(
      context,
      excludeIds: {for (final line in booking.services) line.item.id},
    );
    if (item == null || !mounted) return;

    await _run(() async {
      final error = await bookings.replaceService(booking, item.id);
      if (!mounted) return;
      AppToast.show(
        context,
        error ?? 'Layanan booking diganti ${item.name}',
        error: error != null,
      );
    });
  }

  // Terima bayar pakai nominal server lalu cetak struk
  Future<void> _pay(Booking booking) async {
    final checkout = context.read<CheckoutController>();
    final method = _method;
    if (!checkout.canTakePayment) {
      AppToast.show(
        context,
        context.read<ShiftController>().closedMessage,
        error: true,
      );
      return;
    }

    final cash = await showPaymentDialog(
      context,
      total: booking.total,
      method: method,
    );
    if (cash == null || !mounted) return;

    await _run(() async {
      final result = await checkout.payBooking(
        booking,
        method: method,
        cash: cash,
      );
      if (!mounted) return;
      final receipt = result.receipt;
      if (receipt == null) {
        AppToast.show(context, result.error!, error: true);
        return;
      }

      await printWithRetry(context, receipt.toEscPos(logo: ReceiptLogo.cached));
      if (!mounted) return;
      context.read<BookingsController>().refresh();
      AppToast.show(
        context,
        'Pembayaran booking ${booking.customer.name} berhasil',
      );
    });
  }

  Future<void> _reprint(Booking booking) async {
    // Metode bayar asli tidak disimpan di booking, jadi cetak ulang cuma total
    final receipt = context.read<CheckoutController>().receiptForBooking(
      booking,
      method: _method,
      cash: null,
    );
    final printed = await printWithRetry(
      context,
      receipt.toEscPos(logo: ReceiptLogo.cached),
    );
    if (printed && mounted) AppToast.show(context, 'Struk dicetak ulang');
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingsController>().selected;

    return AppCard(
      child: switch (booking) {
        null => const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Pilih booking',
          message: 'Tap salah satu booking untuk melihat keranjang.',
        ),
        Booking(status: BookingStatus.canceled) => const EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Pesanan dibatalkan',
          message:
              'Booking ini sudah dibatalkan, tidak ada yang perlu dibayar.',
        ),
        _ => _body(booking),
      },
    );
  }

  Widget _body(Booking booking) {
    final shift = context.watch<ShiftController>();
    final catalog = context.watch<CatalogController>();
    final status = booking.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Text('Keranjang', style: AppTextStyle.title),
              const SizedBox(height: 12),
              for (final line in booking.services)
                CartItemTile(
                  item: catalog.byId(line.item.id) ?? line.item,
                  subtitle: booking.capster.name,
                ),
              if (booking.services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Belum ada layanan di booking ini.',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                ),
              if (!status.isFinal) ...[
                SizedBox(
                  height: 38,
                  child: TextButton(
                    style: AppButtonStyle.softGold,
                    // Backend hanya izinkan ubah item saat progress
                    onPressed: status == BookingStatus.progress && !_busy
                        ? () => _replaceService(booking)
                        : null,
                    child: const Text(
                      'Ganti Layanan / Paket',
                      style: AppTextStyle.label,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status == BookingStatus.booked
                      ? 'Layanan bisa diganti setelah pelanggan check-in.'
                      : '1 pelanggan cuma 1 layanan atau 1 paket.',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 10),
        SummaryRow(
          label: 'Subtotal',
          value: PriceFormat.full(booking.subtotal),
        ),
        if (booking.discount > 0)
          SummaryRow(
            label: 'Diskon/Poin',
            value: PriceFormat.full(-booking.discount),
            valueColor: AppColor.danger,
          ),
        const SizedBox(height: 6),
        TotalRow(label: 'Total Bayar', value: PriceFormat.full(booking.total)),
        const SizedBox(height: 12),
        ...switch (status) {
          BookingStatus.booked => [
            FilledButton(
              onPressed: _busy ? null : () => _checkIn(booking),
              child: const Text('Ubah Status Progress'),
            ),
          ],
          BookingStatus.progress => [
            Text(
              'METODE PEMBAYARAN',
              style: AppTextStyle.label.copyWith(
                fontSize: 11,
                color: AppColor.inkSoft,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (index, method) in PaymentType.values.indexed) ...[
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Pill(
                      label: method == PaymentType.cash ? 'Tunai' : 'QRIS',
                      icon: method == PaymentType.cash
                          ? AppAsset.cashIcon
                          : AppAsset.cashlessIcon,
                      style: PillStyle.soft,
                      height: 34,
                      selected: _method == method,
                      onTap: () => setState(() => _method = method),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (!shift.isOpen)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  shift.closedMessage,
                  style: AppTextStyle.caption.copyWith(color: AppColor.danger),
                ),
              ),
            FilledButton.icon(
              onPressed: shift.isOpen && !_busy ? () => _pay(booking) : null,
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Bayar'),
            ),
          ],
          BookingStatus.completed => [
            FilledButton.icon(
              onPressed: () => _reprint(booking),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Cetak Struk'),
            ),
          ],
          BookingStatus.canceled => const [],
        },
      ],
    );
  }
}
