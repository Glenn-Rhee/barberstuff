import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_section.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/capster_selector.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/discount_section.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/payment_dialog.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/display/summary_row.dart';
import 'package:tablet_dashboard/shared/widgets/display/total_row.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Panel kanan pesanan langsung: pelanggan, keranjang, capster, diskon,
// simpan / bayar
class OrderPanel extends StatefulWidget {
  const OrderPanel({super.key});

  @override
  State<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<OrderPanel> {
  bool _busy = false;

  // Cek isian sebelum kirim, balikin capster kalau semua lengkap
  Capster? _validate() {
    final order = context.read<OrderController>();
    final problem = order.isEmpty
        ? 'Pilih layanan dulu'
        : order.customerError ??
              (order.capster == null ? 'Pilih capster dulu' : null);
    if (problem != null) {
      AppToast.show(context, problem, error: true);
      return null;
    }
    return order.capster;
  }

  // Pesanan & pelanggan baru tersimpan, muat ulang daftar terkait
  void _afterCreated() {
    context.read<OrderController>().clearAll();
    context.read<BookingsController>().refresh();
    context.read<CustomerHistoryController>().refresh();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Simpan tanpa bayar: pesanan langsung check-in, bayar nanti dari
  // tab Dari Reservasi. Backend tidak bisa simpan diskon tanpa bayar,
  // jadi diskon diterapkan lagi di sana
  Future<void> _save() async {
    final capster = _validate();
    if (capster == null) return;
    final order = context.read<OrderController>();
    final name = order.customerName;
    final discount = order.discount;

    await _run(() async {
      final result = await context.read<CheckoutController>().startWalkIn(
        order,
        capster: capster,
      );
      if (!mounted) return;
      if (result.created) _afterCreated();
      AppToast.show(
        context,
        result.error ??
            (discount == null
                ? 'Pesanan $name tersimpan. Bayar dari tab Dari Reservasi.'
                : 'Pesanan $name tersimpan. Terapkan lagi diskon '
                      '${discount.label} saat bayar di tab Dari Reservasi.'),
        error: result.error != null,
      );
    });
  }

  // Terima bayar, catat ke server, cetak struk, lalu kosongkan pesanan
  Future<void> _pay() async {
    final capster = _validate();
    if (capster == null) return;
    final order = context.read<OrderController>();
    final checkout = context.read<CheckoutController>();
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
      total: order.total,
      method: order.method,
    );
    if (cash == null || !mounted) return;

    await _run(() async {
      final result = await checkout.payWalkIn(
        order,
        capster: capster,
        cash: cash,
      );
      if (!mounted) return;
      final receipt = result.receipt;
      if (receipt == null) {
        if (result.created) _afterCreated();
        AppToast.show(context, result.error!, error: true);
        return;
      }
      _afterCreated();
      await printWithRetry(context, receipt.toEscPos(logo: ReceiptLogo.cached));
      if (mounted) {
        AppToast.show(context, 'Pembayaran ${receipt.number} berhasil');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderController>();
    final attendance = context.watch<AttendanceController>();
    // Capster yang absen "Tidak Hadir" tidak bisa dipilih
    // (termasuk yang tidak hadir di tablet saja)
    final capsters = [
      for (final capster in context.select<CatalogController, List<Capster>>(
        (c) => c.activeCapsters,
      ))
        if (attendance.statusOf(capster) != AttendanceStatus.absent) capster,
    ];
    final shift = context.watch<ShiftController>();
    final items = order.items;
    final ready = !_busy && items.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomerSection(),
                  const SizedBox(height: 16),
                  const Text('Keranjang', style: AppTextStyle.label),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Belum ada layanan.\nBoleh lebih dari 1 service / paket.',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.caption.copyWith(
                          color: AppColor.inkSoft,
                        ),
                      ),
                    ),
                  for (final item in items)
                    CartItemTile(
                      item: item,
                      subtitle: item.type.label,
                      onRemove: _busy ? null : () => order.remove(item),
                    ),
                  const SizedBox(height: 16),
                  const Text('Pilih Capster', style: AppTextStyle.label),
                  const SizedBox(height: 8),
                  CapsterSelector(
                    value: order.capster,
                    options: capsters,
                    onChanged: order.setCapster,
                    loading: context.select<CatalogController, bool>(
                      (c) => c.loadingCapsters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DiscountSection(
                    value: order.discount,
                    base: order.subtotal,
                    onChanged: ready ? order.setDiscount : null,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          SummaryRow(
            label: 'Subtotal',
            value: PriceFormat.full(order.subtotal),
          ),
          if (order.discount case final discount? when order.discountAmount > 0)
            SummaryRow(
              label: discount.summaryLabel,
              value: PriceFormat.full(-order.discountAmount),
              valueColor: AppColor.danger,
            ),
          const SizedBox(height: 6),
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
                        ? AppAsset.cashIcon
                        : AppAsset.cashlessIcon,
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
          OutlinedButton(
            onPressed: ready ? _save : null,
            child: const Text('Simpan Pesanan'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: ready && shift.isOpen ? _pay : null,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.surface,
                    ),
                  )
                : const Icon(Icons.print_outlined, size: 18),
            // Shift tutup: alasannya langsung di tombol, hemat tempat
            label: Text(
              shift.isOpen
                  ? 'Bayar & Cetak Struk'
                  : shift.enabled
                  ? 'Buka shift dulu untuk bayar'
                  : 'Bayar khusus akun kasir',
            ),
          ),
        ],
      ),
    );
  }
}
