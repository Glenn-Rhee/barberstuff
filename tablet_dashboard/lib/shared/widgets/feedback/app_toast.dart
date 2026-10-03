import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Pesan singkat di bawah layar, merah kalau error
class AppToast {
  const AppToast._();

  static void show(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyle.body.copyWith(color: AppColor.surface),
          ),
          backgroundColor: error ? AppColor.danger : AppColor.ink,
          width: 480,
        ),
      );
  }
}
