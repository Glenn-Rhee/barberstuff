import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/payment_dialog.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_status_badge.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/scan_qr_dialog.dart';
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

// Detail dan pembayaran booking yang dipilih, nominal dari server
class BookingPanel extends StatefulWidget {
  const BookingPanel({super.key});

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel> {
  PaymentType _method = PaymentType.cash;

  Future<void> _addService(Booking booking) async {
    final bookings = context.read<BookingsController>();
    final item = await showServicePicker(context);
    if (item == null || !mounted) return;

    final error = await bookings.addService(booking, item.id);
    if (!mounted) return;
    AppToast.show(
      context,
      error ?? 'Layanan ditambahkan ke booking',
      error: error != null,
    );
  }

  // Terima bayar pakai nominal server lalu cetak struk
  Future<void> _pay(Booking booking) async {
    final checkout = context.read<CheckoutController>();
    final method = _method;
    if (!checkout.canTakePayment) {
      AppToast.show(context, 'Buka shift kasir dulu di Dashboard', error: true);
      return;
    }

    final cash = await showPaymentDialog(
      context,
      total: booking.total,
      method: method,
    );
    if (cash == null || !mounted) return;

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
      child: booking == null
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Pilih booking',
              message:
                  'Tap salah satu booking untuk melihat detail dan pembayaran.',
            )
          : _body(booking),
    );
  }

  Widget _body(Booking booking) {
    final shiftOpen = context.select<ShiftController, bool>((s) => s.isOpen);
    final editable = !booking.status.isFinal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Keranjang', style: AppTextStyle.title),
                  ),
                  BookingStatusText(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              for (final line in booking.services)
                CartItemTile(line: line, subtitle: booking.capster.name),
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
              const SizedBox(height: 16),
              const Text('Pelanggan', style: AppTextStyle.label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.customer.name, style: AppTextStyle.bodyBold),
                    Text(
                      booking.customer.phone ?? 'Tanpa nomor telepon',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                    if (booking.customer.isMember)
                      Text(
                        '${booking.customer.premiumType} · ${PriceFormat.plain(booking.customer.memberPoints)} poin',
                        style: AppTextStyle.caption.copyWith(
                          color: AppColor.gold,
                        ),
                      ),
                  ],
                ),
              ),
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
            label: 'Diskon',
            value: PriceFormat.full(-booking.discount),
            valueColor: AppColor.danger,
          ),
        const SizedBox(height: 6),
        TotalRow(label: 'Total Bayar', value: PriceFormat.full(booking.total)),
        const SizedBox(height: 12),
        ...switch (booking.status) {
          BookingStatus.completed => [
            const _Note(
              icon: Icons.check_circle,
              text: 'Booking selesai',
              color: AppColor.success,
              background: AppColor.successSoft,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _reprint(booking),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Cetak Ulang Struk'),
            ),
          ],
          BookingStatus.canceled => [
            const _Note(
              icon: Icons.cancel,
              text: 'Booking dibatalkan',
              color: AppColor.danger,
              background: AppColor.dangerSoft,
            ),
          ],
          // Server baru terima bayar setelah check-in (status progress)
          BookingStatus.booked => [
            const _Note(
              icon: Icons.info_outline,
              text: 'Pelanggan belum check-in. Scan QR booking dulu sebelum bayar.',
              color: AppColor.info,
              background: AppColor.infoSoft,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              // Mode debug isi otomatis QR booking (bk{id}) untuk tes
              onPressed: () => scanQrAndCheckIn(
                context,
                initialCode: kDebugMode ? 'bk${booking.id}' : null,
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scan QR Check-in'),
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
            if (!shiftOpen)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Shift kasir belum dibuka.',
                  style: AppTextStyle.caption.copyWith(color: AppColor.danger),
                ),
              ),
            FilledButton.icon(
              onPressed: shiftOpen ? () => _pay(booking) : null,
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Bayar & Cetak Struk'),
            ),
          ],
        },
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyle.label.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
