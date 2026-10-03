import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';

// Penanda "● Shift Buka" / "● Shift Tutup"
class ShiftStatusChip extends StatelessWidget {
  const ShiftStatusChip({super.key, this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final open = context.select<ShiftController, bool>((s) => s.isOpen);
    final color = open ? AppColor.success : AppColor.danger;

    return Container(
      height: filled ? 28 : null,
      padding: filled
          ? const EdgeInsets.symmetric(horizontal: 10)
          : EdgeInsets.zero,
      decoration: filled
          ? BoxDecoration(
              color: open ? AppColor.successSoft : AppColor.dangerSoft,
              borderRadius: BorderRadius.circular(999),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            open ? 'Shift Buka' : 'Shift Tutup',
            style: AppTextStyle.label.copyWith(
              color: filled ? color : AppColor.ink,
            ),
          ),
        ],
      ),
    );
  }
}
