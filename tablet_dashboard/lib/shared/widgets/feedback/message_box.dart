import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Kotak pesan berwarna: merah untuk error, hijau untuk berhasil
class MessageBox extends StatelessWidget {
  const MessageBox({super.key, required this.message, this.success = false});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColor.success : AppColor.danger;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? AppColor.successSoft : AppColor.dangerSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
