import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/discount.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';

<<<<<<< HEAD
// "Diskon Produk": pilih persen / nominal, isi jumlah, lalu Terapkan.
// [value] = diskon yang sedang dipakai, [base] = total sebelum diskon.
// [onChanged] null = terkunci (mis. booking belum check-in), alasannya di [note]
=======
// Diskon persen / nominal. [onChanged] null = terkunci, alasan di [note]
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
class DiscountSection extends StatefulWidget {
  const DiscountSection({
    super.key,
    required this.value,
    required this.base,
    required this.onChanged,
    this.note,
  });

  final Discount? value;
  final int base;
  final ValueChanged<Discount?>? onChanged;
  final String? note;

  @override
  State<DiscountSection> createState() => _DiscountSectionState();
}

class _DiscountSectionState extends State<DiscountSection> {
  late DiscountType _type = widget.value?.type ?? DiscountType.percent;
  late final _controller = TextEditingController(text: _textOf(widget.value));

  bool get _enabled => widget.onChanged != null;

  Discount get _draft =>
      Discount(_type, ThousandsFormatter.parse(_controller.text));

  // Error baru muncul setelah kasir mengetik
  String? get _error =>
      _controller.text.isEmpty ? null : _draft.errorFor(widget.base);

  bool get _canApply =>
      _enabled &&
      _controller.text.isNotEmpty &&
      _error == null &&
      _draft != widget.value;

  static String _textOf(Discount? discount) => switch (discount) {
    null => '',
    Discount(isPercent: true) => '${discount.value}',
    _ => PriceFormat.plain(discount.value),
  };

  @override
  void didUpdateWidget(DiscountSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dikosongkan dari luar (Hapus Semua / sudah dibayar)
    if (oldWidget.value != null && widget.value == null) _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Ganti jenis = angka lama tidak berarti lagi, jadi isian & diskon dihapus
  void _setType(DiscountType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _controller.clear();
    });
    if (widget.value != null) widget.onChanged?.call(null);
  }

  void _apply() {
    if (!_canApply) return;
    FocusScope.of(context).unfocus();
    widget.onChanged?.call(_draft);
  }

  void _remove() {
    _controller.clear();
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final applied = widget.value;
    final percent = _type == DiscountType.percent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Diskon Produk', style: AppTextStyle.label),
        const SizedBox(height: 8),
        Opacity(
          opacity: _enabled ? 1 : 0.5,
          child: Row(
            children: [
              for (final (index, type) in DiscountType.values.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: Pill(
                    label: type.label,
                    style: PillStyle.soft,
                    height: 34,
                    selected: _type == type,
                    onTap: _enabled ? () => _setType(type) : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          enabled: _enabled,
          keyboardType: TextInputType.number,
          inputFormatters: percent
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ]
              : const [ThousandsFormatter()],
          style: AppTextStyle.bodyBold,
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah diskon',
            errorText: _error,
            prefixIcon: percent ? null : const _Affix('Rp', left: true),
            suffixIcon: percent ? const _Affix('%', left: false) : null,
            prefixIconConstraints: const BoxConstraints(),
            suffixIconConstraints: const BoxConstraints(),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _apply(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: FilledButton(
            onPressed: _canApply ? _apply : null,
            child: const Text('Terapkan Diskon'),
          ),
        ),
        if (applied != null) ...[
          const SizedBox(height: 8),
          _AppliedDiscount(
            discount: applied,
            amount: applied.amountFor(widget.base),
            onRemove: _enabled ? _remove : null,
          ),
        ],
        if (widget.note case final note?) ...[
          const SizedBox(height: 6),
          Text(
            note,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
        ],
      ],
    );
  }
}

// "Rp" di kiri atau "%" di kanan kotak isian
class _Affix extends StatelessWidget {
  const _Affix(this.text, {required this.left});

  final String text;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: left
          ? const EdgeInsets.only(left: 12, right: 8)
          : const EdgeInsets.only(left: 8, right: 12),
      child: Text(
        text,
        style: AppTextStyle.bodyBold.copyWith(color: AppColor.inkSoft),
      ),
    );
  }
}

// Penanda diskon aktif + potongannya, bisa dihapus
class _AppliedDiscount extends StatelessWidget {
  const _AppliedDiscount({
    required this.discount,
    required this.amount,
    required this.onRemove,
  });

  final Discount discount;
  final int amount;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
      decoration: BoxDecoration(
        color: AppColor.successSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColor.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Diskon ${discount.label} diterapkan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.label,
            ),
          ),
          Text(
            PriceFormat.full(-amount),
            style: AppTextStyle.label.copyWith(color: AppColor.danger),
          ),
          // Disembunyikan selagi proses bayar
          if (onRemove != null)
            SizedBox.square(
              dimension: 32,
              child: IconButton(
                tooltip: 'Hapus diskon',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColor.inkSoft,
                ),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
