import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../shared/models/person.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../dashboard/domain/cash_session.dart';
import '../../../dashboard/presentation/provider/shift_controller.dart';
import '../checkout.dart';
import '../provider/catalog_controller.dart';
import '../provider/order_controller.dart';
import 'cart_item_tile.dart';

/// Right-hand panel of "Pesanan Langsung": customer, cart, capster and payment.
class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key});

  Future<void> _pay(BuildContext context) async {
    final order = context.read<OrderController>();
    final capster = order.capster;
    if (capster == null) {
      AppToast.show(context, 'Pilih capster dulu', error: true);
      return;
    }
    await checkoutWalkIn(context, capster: capster);
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderController>();
    final capsters = context.select<CatalogController, List<Capster>>((c) => c.activeCapsters);
    final shiftOpen = context.select<ShiftController, bool>((s) => s.isOpen);
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
                    const Expanded(child: Text('Data Pelanggan', style: AppTextStyle.bodyStrong)),
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
                  decoration: const InputDecoration(hintText: 'Nama Pelanggan (opsional)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: order.phoneController,
                  style: AppTextStyle.body,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Nomor Telepon (opsional)'),
                ),
                const SizedBox(height: 16),
                const Text('Keranjang', style: AppTextStyle.label),
                const SizedBox(height: 8),
                if (lines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColor.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Belum ada layanan.\nTap "+ Tambah" di sebelah kiri.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption,
                    ),
                  ),
                for (final line in lines)
                  CartItemTile(line: line, subtitle: line.item.type.label, onRemove: () => order.remove(line.item)),
                const SizedBox(height: 16),
                const Text('Pilih Capster', style: AppTextStyle.label),
                const SizedBox(height: 8),
                _CapsterSelector(value: order.capster, options: capsters, onChanged: order.setCapster),
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
                    icon: method == PaymentType.cash ? Icons.attach_money : Icons.qr_code_2,
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
                'Shift kasir belum dibuka. Buka shift di Dashboard untuk menerima pembayaran.',
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

class _CapsterSelector extends StatelessWidget {
  const _CapsterSelector({required this.value, required this.options, required this.onChanged});

  final Capster? value;
  final List<Capster> options;
  final ValueChanged<Capster> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    return PopupMenuButton<Capster>(
      tooltip: 'Pilih capster',
      position: PopupMenuPosition.under,
      enabled: options.isNotEmpty,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final capster in options)
          PopupMenuItem(
            value: capster,
            child: Row(
              children: [
                PersonAvatar(name: capster.name, photo: capster.photoUrl, size: 30),
                const SizedBox(width: 10),
                Text(capster.name, style: AppTextStyle.body),
                if (capster.rating > 0) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.star_rounded, size: 14, color: AppColor.gold),
                  Text(capster.rating.toStringAsFixed(1), style: AppTextStyle.caption),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          children: [
            if (value == null)
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColor.surfaceMuted,
                child: Icon(Icons.content_cut, size: 16, color: AppColor.inkFaint),
              )
            else
              PersonAvatar(name: value.name, photo: value.photoUrl),
            const SizedBox(width: 10),
            Expanded(
              child: value == null
                  ? Text(
                      options.isEmpty ? 'Capster belum tersedia' : 'Pilih capster',
                      style: AppTextStyle.body.copyWith(color: AppColor.inkFaint),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value.name, style: AppTextStyle.bodyStrong),
                        if (value.rating > 0)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColor.gold),
                              const SizedBox(width: 2),
                              Text(
                                value.rating.toStringAsFixed(1),
                                style: AppTextStyle.caption.copyWith(color: AppColor.ink),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColor.inkSoft),
          ],
        ),
      ),
    );
  }
}
