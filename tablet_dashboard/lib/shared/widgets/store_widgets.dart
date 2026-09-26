import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';
import '../../features/dashboard/presentation/provider/shift_controller.dart';

/// "● Shift Buka" indicator; the till is open only while a cash session runs.
class ShiftStatusChip extends StatelessWidget {
  const ShiftStatusChip({super.key, this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final open = context.select<ShiftController, bool>((s) => s.isOpen);
    final color = open ? AppColor.successDot : AppColor.danger;

    return Container(
      height: filled ? 28 : null,
      padding: filled ? const EdgeInsets.symmetric(horizontal: 10) : EdgeInsets.zero,
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
            style: AppTextStyle.label.copyWith(color: filled ? color : AppColor.ink),
          ),
        ],
      ),
    );
  }
}
