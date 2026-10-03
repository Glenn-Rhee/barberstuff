import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';

// Balikin uang yang diterima (non tunai = [total]), null kalau batal
Future<int?> showPaymentDialog(
  BuildContext context, {
  required int total,
  required PaymentType method,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _PaymentDialog(total: total, method: method),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.total, required this.method});

  final int total;
  final PaymentType method;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _cashController = TextEditingController();
  late int _cash = widget.total;

  bool get _isCash => widget.method == PaymentType.cash;

  // Tiga nominal bulat di atas total, mis. 55.000 -> 60.000, 100.000, 200.000
  static List<int> quickAmounts(int total) {
    final next10k = (total ~/ 10000 + 1) * 10000;
    final next50k = (total ~/ 50000 + 1) * 50000;
    final next100k = (total ~/ 100000 + 1) * 100000;
    return ({
      next10k,
      next50k,
      next100k,
      next100k + 100000,
    }.toList()..sort()).take(3).toList();
  }

  void _setCash(int value) {
    setState(() => _cash = value);
    _cashController.text = PriceFormat.plain(value);
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final change = _cash - widget.total;
    final enough = !_isCash || change >= 0;

    return AlertDialog(
      title: Text(
        'Pembayaran ${widget.method.label}',
        style: AppTextStyle.title,
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.goldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Bayar',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  Text(
                    PriceFormat.full(widget.total),
                    style: AppTextStyle.h1.copyWith(color: AppColor.gold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isCash) ...[
              const Text('Uang diterima', style: AppTextStyle.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(
                    label: 'Uang pas',
                    selected: _cash == widget.total,
                    onTap: () => _setCash(widget.total),
                  ),
                  for (final amount in quickAmounts(widget.total))
                    Pill(
                      label: PriceFormat.plain(amount),
                      selected: _cash == amount,
                      onTap: () => _setCash(amount),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyle.body,
                decoration: const InputDecoration(
                  hintText: 'Nominal lain',
                  prefixText: 'Rp ',
                ),
                onChanged: (value) =>
                    setState(() => _cash = int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Kembalian',
                    style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
                  ),
                  const Spacer(),
                  Text(
                    enough ? PriceFormat.full(change) : 'Uang kurang',
                    style: AppTextStyle.title.copyWith(
                      color: enough ? AppColor.ink : AppColor.danger,
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Minta pelanggan membayar lewat QRIS / EDC. Tekan konfirmasi setelah pembayaran berhasil.',
                style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
              ),
          ],
        ),
      ),
      actions: [
        const DialogCancelButton(),
        FilledButton.icon(
          onPressed: enough
              ? () => Navigator.pop(context, _isCash ? _cash : widget.total)
              : null,
          icon: const Icon(Icons.print_outlined, size: 18),
          label: const Text('Konfirmasi & Cetak'),
        ),
      ],
    );
  }
}
