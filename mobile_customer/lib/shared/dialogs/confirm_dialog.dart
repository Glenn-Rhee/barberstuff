import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// Dialog dua tombol: batal (kiri) dan konfirmasi (kanan).
/// Mengembalikan true hanya kalau tombol konfirmasi ditekan.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  Color confirmColor = AppColor.goldDeep,
}) async {
  final bool? answer = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: AppTextStyle.titleMedium),
      content: Text(
        message,
        style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            cancelLabel,
            style: AppTextStyle.labelMedium.copyWith(color: AppColor.inkSoft),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: AppTextStyle.labelMedium.copyWith(
              color: confirmColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  return answer ?? false;
}
