import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/discount.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/discount_section.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/payment_dialog.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/widgets/cancel_booking_dialog.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/widgets/service_picker_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/display/summary_row.dart';
import 'package:tablet_dashboard/shared/widgets/display/total_row.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Aksi booking: booked = check-in, progress = bayar, completed = struk
class BookingPanel extends StatefulWidget {
  const BookingPanel({super.key});

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel> {
  PaymentType _method = PaymentType.cash;
  bool _busy = false;

  // Diskon kasir milik satu booking, pindah booking = tidak ikut
  ({String bookingId, Discount discount})? _discount;

  // Diskon hanya berlaku saat progress (backend cuma terima saat bayar)
  Discount? _discountOf(Booking booking) =>
      booking.status == BookingStatus.progress &&
          _discount?.bookingId == booking.id
      ? _discount!.discount
      : null;

  void _setDiscount(Booking booking, Discount? value) => setState(
    () => _discount = value == null
        ? null
        : (bookingId: booking.id, discount: value),
  );

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Booked -> Progress lewat check-in pakai QR booking
  Future<void> _checkIn(Booking booking) => _run(() async {
    final bookings = context.read<BookingsController>();
    final error = await bookings.checkInBooking(booking);
    if (!mounted) return;
    if (error == null) {
      await bookings.focus(booking.id, day: booking.scheduledAt);
    }
    if (!mounted) return;
    AppToast.show(
      context,
      error ?? '${booking.customer.name} sudah check-in',
      error: error != null,
    );
  });

  // Item yang sudah ada tidak muncul di pemilih
  Future<void> _addService(Booking booking) async {
    final bookings = context.read<BookingsController>();
    final item = await showServicePicker(
      context,
      excludeIds: {for (final line in booking.services) line.item.id},
    );
    if (item == null || !mounted) return;

    await _run(() async {
      final error = await bookings.addService(booking, item.id);
      if (!mounted) return;
      AppToast.show(
        context,
        error ?? '${item.name} ditambahkan ke booking',
        error: error != null,
      );
    });
  }

  // +1 (POST item) / -1 (DELETE item), jumlah baru dibaca lagi dari server
  Future<void> _changeQty(Booking booking, ServiceItem item, int delta) =>
      _run(() async {
        final bookings = context.read<BookingsController>();
        final before = booking.qtyOf(item.id);
        final error = delta > 0
            ? await bookings.addService(booking, item.id)
            : await bookings.removeService(booking, item.id);
        if (!mounted) return;
        if (error != null) {
          AppToast.show(context, error, error: true);
          return;
        }
        // Server bisa balas sukses tapi jumlahnya tidak berubah
        final after = bookings.selected?.qtyOf(item.id);
        if (after != null && after != before + delta) {
          AppToast.show(
            context,
            'Server belum mengubah jumlah ${item.name} '
            '(tetap x$after).',
            error: true,
          );
        }
      });

  // Terima bayar pakai nominal server (dikurangi diskon kasir) lalu cetak
  Future<void> _pay(Booking booking) async {
    final checkout = context.read<CheckoutController>();
    final method = _method;
    final discount = _discountOf(booking);
    final total = booking.total - (discount?.amountFor(booking.total) ?? 0);
    if (!checkout.canTakePayment) {
      AppToast.show(
        context,
        context.read<ShiftController>().closedMessage,
        error: true,
      );
      return;
    }

    final cash = await showPaymentDialog(context, total: total, method: method);
    if (cash == null || !mounted) return;

    await _run(() async {
      final result = await checkout.payBooking(
        booking,
        method: method,
        cash: cash,
        discount: discount,
      );
      if (!mounted) return;
      final receipt = result.receipt;
      if (receipt == null) {
        AppToast.show(context, result.error!, error: true);
        return;
      }

      setState(() => _discount = null);
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

  // Batalkan booking (booked/progress)
  Future<void> _cancel(Booking booking) async {
    final bookings = context.read<BookingsController>();
    final cancelled = await showCancelBookingDialog(
      context,
      onSubmit: (reason) => bookings.cancel(booking, reason),
    );
    if (!cancelled || !mounted) return;
    context.read<BookingsController>().refresh();
    AppToast.show(context, 'Pesanan ${booking.customer.name} dibatalkan');
  }

  // Batalkan booking (Completed)
  Future<void> _cancelWhenCompleted(Booking booking) async {
    final bookings = null;
    final cancelled = null;
    showCancelBookingDialog(
      context,
      onSubmit: (reason) => bookings.cancel(booking: reason),
    );
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
    // Backend hanya izinkan ubah item saat progress, dan booking tidak boleh kosong
    final editable = status == BookingStatus.progress && !_busy;
    final removable = editable && booking.itemCount > 1;
    final discount = _discountOf(booking);
    final discountAmount = discount?.amountFor(booking.total) ?? 0;

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
                  qty: line.qty,
                  onAdd: editable
                      ? () => _changeQty(booking, line.item, 1)
                      : null,
                  onRemove: removable
                      ? () => _changeQty(booking, line.item, -1)
                      : null,
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
                    onPressed: editable ? () => _addService(booking) : null,
                    child: const Text(
                      'Tambah Layanan / Paket',
                      style: AppTextStyle.label,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status == BookingStatus.booked
                      ? 'Layanan bisa ditambah setelah pelanggan check-in.'
                      : 'Boleh lebih dari 1 layanan / paket. '
                            'Tekan + di keranjang untuk menambah jumlah.',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
                const SizedBox(height: 20),
                DiscountSection(
                  // Isian kosong lagi tiap ganti booking
                  key: ValueKey(booking.id),
                  value: discount,
                  base: booking.total,
                  onChanged: editable
                      ? (value) => _setDiscount(booking, value)
                      : null,
                  note: status == BookingStatus.booked
                      ? 'Diskon bisa dipakai setelah pelanggan check-in '
                            '(status Progress).'
                      : null,
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
        if (booking.totalDiscount > 0)
          SummaryRow(
            label: 'Diskon/Poin',
            value: PriceFormat.full(-booking.totalDiscount),
            valueColor: AppColor.danger,
          ),
        if (discount != null && discountAmount > 0)
          SummaryRow(
            label: discount.summaryLabel,
            value: PriceFormat.full(-discountAmount),
            valueColor: AppColor.danger,
          ),
        const SizedBox(height: 6),
        TotalRow(
          label: 'Total Bayar',
          value: PriceFormat.full(booking.total - discountAmount),
        ),
        const SizedBox(height: 12),
        ...switch (status) {
          // INI KALO BOOKINGNYA MASIH BOOKED
          BookingStatus.booked => [
            FilledButton(
              onPressed: _busy ? null : () => _checkIn(booking),
              child: const Text('Ubah Status Progress'),
            ),
            const SizedBox(height: 8),
            _cancelButton(booking),
          ],

          // INI KALO BOOKINGNYA PRGORESS
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
            _cancelButton(booking),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: shift.isOpen && !_busy ? () => _pay(booking) : null,
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Bayar'),
            ),
          ],

          // INI KALO COMPLETED BOOKINGNYA
          BookingStatus.completed => [
            // TUNGGU API
            _cancelButtonWhenCompleted(booking),
            const SizedBox(height: 8),
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

  Widget _cancelButton(Booking booking) => OutlinedButton(
    style: AppButtonStyle.dangerFilled,
    onPressed: _busy ? null : () => _cancel(booking),
    child: const Text('Cancel Pesanan'),
  );

  Widget _cancelButtonWhenCompleted(Booking booking) => OutlinedButton(
    style: AppButtonStyle.dangerFilled,
    onPressed: _busy ? null : () => _cancelWhenCompleted(booking),
    child: const Text("Cancel Pesanan"),
  );
}
