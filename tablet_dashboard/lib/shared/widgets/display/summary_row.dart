import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Baris ringkasan tagihan, mis. "Subtotal   Rp 50.000"
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Label panjang dipotong, nominal selalu utuh
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyle.label.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
