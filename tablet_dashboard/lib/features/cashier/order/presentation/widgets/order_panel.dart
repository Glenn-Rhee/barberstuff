import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/capster_selector.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/payment_dialog.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/display/total_row.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Panel kanan "Pesanan Langsung": pelanggan, keranjang, capster, bayar
class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key});

  // Terima bayar, catat ke server, cetak struk, lalu kosongkan pesanan
  Future<void> _pay(BuildContext context) async {
    final order = context.read<OrderController>();
    final checkout = context.read<CheckoutController>();

    final capster = order.capster;
    if (capster == null) {
      AppToast.show(context, 'Pilih capster dulu', error: true);
      return;
    }
    if (!checkout.canTakePayment) {
      AppToast.show(context, 'Buka shift kasir dulu di Dashboard', error: true);
      return;
    }

    final cash = await showPaymentDialog(
      context,
      total: order.total,
      method: order.method,
    );
    if (cash == null || !context.mounted) return;

    final result = await checkout.payWalkIn(
      order,
      capster: capster,
      cash: cash,
    );
    if (!context.mounted) return;
    final receipt = result.receipt;
    if (receipt == null) {
      AppToast.show(context, result.error!, error: true);
      return;
    }

    await printWithRetry(context, receipt.toEscPos(logo: ReceiptLogo.cached));
    if (!context.mounted) return;

    order.clearAll();
    context.read<BookingsController>().refresh();
    AppToast.show(context, 'Pembayaran ${receipt.number} berhasil');
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderController>();
    final attendance = context.watch<AttendanceController>();
    // Capster yang absen "Tidak Hadir" tidak bisa dipilih
    final capsters = [
      for (final capster in context.select<CatalogController, List<Capster>>(
        (c) => c.activeCapsters,
      ))
        if (!attendance.isAbsent(capster.id)) capster,
    ];
    final shift = context.watch<ShiftController>();
    final shiftOpen = shift.isOpen;
    final lines = order.lines;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Data Pelanggan',
                        style: AppTextStyle.bodyBold,
                      ),
                    ),
                    TextButton(
                      onPressed: order.clearAll,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.danger,
                        visualDensity: VisualDensity.compact,
                        textStyle: AppTextStyle.label,
                      ),
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: order.nameController,
                  style: AppTextStyle.body,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Nama Pelanggan (opsional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: order.phoneController,
                  style: AppTextStyle.body,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Nomor Telepon (opsional)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Keranjang', style: AppTextStyle.label),
                const SizedBox(height: 8),
                if (lines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Belum ada layanan.\nTap "+ Tambah" di sebelah kiri.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ),
                for (final line in lines)
                  CartItemTile(
                    line: line,
                    subtitle: line.item.type.label,
                    onRemove: () => order.remove(line.item),
                  ),
                const SizedBox(height: 16),
                const Text('Pilih Capster', style: AppTextStyle.label),
                const SizedBox(height: 8),
                CapsterSelector(
                  value: order.capster,
                  options: capsters,
                  onChanged: order.setCapster,
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          TotalRow(label: 'Total', value: PriceFormat.full(order.total)),
          const SizedBox(height: 10),
          const Text('Metode Pembayaran', style: AppTextStyle.label),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (index, method) in PaymentType.values.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: Pill(
                    label: method.label,
                    icon: method == PaymentType.cash
                        ? Icons.attach_money
                        : Icons.qr_code_2,
                    style: PillStyle.soft,
                    height: 34,
                    selected: order.method == method,
                    onTap: () => order.setMethod(method),
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
                shift.closedMessage,
                style: AppTextStyle.caption.copyWith(color: AppColor.danger),
              ),
            ),
          FilledButton.icon(
            onPressed: lines.isEmpty || !shiftOpen ? null : () => _pay(context),
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Bayar & Cetak Struk'),
          ),
        ],
      ),
    );
  }
}
