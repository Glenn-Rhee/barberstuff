import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Bar merah kecil dengan pesan error dan tombol "Coba lagi"
class ErrorBar extends StatelessWidget {
  const ErrorBar({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.dangerSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AppColor.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.label.copyWith(color: AppColor.danger),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
