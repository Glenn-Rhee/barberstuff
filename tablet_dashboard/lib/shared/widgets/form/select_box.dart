import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Kotak pilihan selebar induknya, menu di bawahnya selebar kotak.
// Garis emas saat menu terbuka, pilihan yang dipakai berlatar krem
class SelectBox<T extends Object> extends StatefulWidget {
  const SelectBox({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.hint = 'Pilih',
    this.enabledOf,
  });

  final T? value;
  final List<T> options;
  final String Function(T) labelOf;

  // null = terkunci
  final ValueChanged<T>? onChanged;
  final String hint;

  // Pilihan yang tidak bisa dipilih, mis. role yang sudah ada
  final bool Function(T)? enabledOf;

  @override
  State<SelectBox<T>> createState() => _SelectBoxState<T>();
}

class _SelectBoxState<T extends Object> extends State<SelectBox<T>> {
  bool _open = false;

  void _setOpen(bool value) {
    if (mounted) setState(() => _open = value);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;

    return LayoutBuilder(
      builder: (context, constraints) => PopupMenuButton<T>(
        enabled: widget.onChanged != null,
        tooltip: '',
        // Di atas toast, bukan di dalam navigator halaman
        useRootNavigator: true,
        position: PopupMenuPosition.under,
        menuPadding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
        onOpened: () => _setOpen(true),
        onCanceled: () => _setOpen(false),
        onSelected: (option) {
          _setOpen(false);
          widget.onChanged?.call(option);
        },
        itemBuilder: (_) => [
          for (final option in widget.options)
            PopupMenuItem(
              value: option,
              enabled: widget.enabledOf?.call(option) ?? true,
              padding: EdgeInsets.zero,
              child: _Item(
                label: widget.labelOf(option),
                selected: option == value,
                enabled: widget.enabledOf?.call(option) ?? true,
              ),
            ),
        ],
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.onChanged == null
                ? AppColor.surfaceMuted
                : AppColor.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _open ? AppColor.gold : AppColor.borderStrong,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null ? widget.hint : widget.labelOf(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(
                    color: value == null ? AppColor.inkFaint : AppColor.ink,
                  ),
                ),
              ),
              Icon(
                _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: AppColor.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: selected ? AppColor.goldSoft : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        label,
        style: AppTextStyle.body.copyWith(
          color: !enabled
              ? AppColor.inkFaint
              : selected
              ? AppColor.gold
              : AppColor.ink,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}
