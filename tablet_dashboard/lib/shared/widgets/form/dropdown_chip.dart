import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Kotak pilihan kecil (filter / urutan), tinggi 44 sama dengan kolom cari
class DropdownChip<T> extends StatelessWidget {
  const DropdownChip({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.prefix = '',
  });

  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  // Teks di depan nilai, mis. "Urutkan: "
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: '',
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem(
            value: option,
            child: Text(labelOf(option), style: AppTextStyle.body),
          ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$prefix${labelOf(value)}', style: AppTextStyle.body),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColor.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}
