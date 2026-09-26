import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../cashier/presentation/checkout.dart';
import '../../../cashier/presentation/widgets/cart_item_tile.dart';
import '../../../dashboard/domain/cash_session.dart';
import '../../../dashboard/presentation/provider/shift_controller.dart';
import '../../domain/booking.dart';
import '../provider/bookings_controller.dart';
import 'bookings_view.dart';
import 'service_picker_dialog.dart';

/// Detail and payment for the selected booking. Amounts come from the server.
class BookingPanel extends StatefulWidget {
  const BookingPanel({super.key});

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel> {
  PaymentType _method = PaymentType.cash;

  Future<void> _addService(Booking booking) async {
    final item = await showServicePicker(context);
    if (item == null || !mounted) return;
    await addServiceToBooking(context, booking, item.id);
  }

  Future<void> _reprint(Booking booking) async {
    // The original payment type isn't stored on the booking, so a reprint shows totals only.
    final printed = await printBookingReceipt(context, booking, method: _method, cash: null);
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
              message: 'Tap salah satu booking untuk melihat detail dan pembayaran.',
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
                  const Expanded(child: Text('Keranjang', style: AppTextStyle.sectionTitle)),
                  StatusBadgeSmall(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              for (final line in booking.services) CartItemTile(line: line, subtitle: booking.capster.name),
              if (booking.services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColor.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
                  child: Text('Belum ada layanan di booking ini.', style: AppTextStyle.caption),
                ),
              SizedBox(
                height: 38,
                child: TextButton(
                  style: softGoldStyle(),
                  onPressed: editable ? () => _addService(booking) : null,
                  child: const Text('Tambah Layanan / Paket', style: AppTextStyle.label),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Pelanggan', style: AppTextStyle.label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColor.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.customer.name, style: AppTextStyle.bodyStrong),
                    Text(booking.customer.phone ?? 'Tanpa nomor telepon', style: AppTextStyle.caption),
                    if (booking.customer.isMember)
                      Text(
                        '${booking.customer.premiumType} · ${PriceFormat.plain(booking.customer.memberPoints)} poin',
                        style: AppTextStyle.caption.copyWith(color: AppColor.gold),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 10),
        SummaryRow(label: 'Subtotal', value: PriceFormat.full(booking.subtotal)),
        if (booking.discount > 0)
          SummaryRow(label: 'Diskon', value: PriceFormat.full(-booking.discount), valueColor: AppColor.danger),
        const SizedBox(height: 6),
        TotalRow(label: 'Total Bayar', value: PriceFormat.full(booking.total)),
        const SizedBox(height: 12),
        ...switch (booking.status) {
          BookingStatus.completed => [
            _Note(
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
            _Note(
              icon: Icons.cancel,
              text: 'Booking dibatalkan',
              color: AppColor.danger,
              background: AppColor.dangerSoft,
            ),
          ],
          _ => [
            Text('METODE PEMBAYARAN', style: AppTextStyle.overline),
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
                child: Text('Shift kasir belum dibuka.', style: AppTextStyle.caption.copyWith(color: AppColor.danger)),
              ),
            FilledButton.icon(
              onPressed: shiftOpen ? () => checkoutBooking(context, booking, method: _method) : null,
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Bayar & Cetak Struk'),
            ),
          ],
        },
      ],
    );
  }
}

class StatusBadgeSmall extends StatelessWidget {
  const StatusBadgeSmall({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) => Text(status.label, style: AppTextStyle.caption);
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, required this.color, required this.background});

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
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
