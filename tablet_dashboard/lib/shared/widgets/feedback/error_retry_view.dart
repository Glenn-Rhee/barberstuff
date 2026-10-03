import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Pengganti list saat gagal dimuat: apa yang gagal, kenapa, dan tombol ulang
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColor.inkFaint),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyle.bodyBold),
          const SizedBox(height: 2),
          Text(
            message,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
