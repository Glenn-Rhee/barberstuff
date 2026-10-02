import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final radius = BorderRadius.circular(10);
    const buttonText = AppTextStyle.button;

    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color),
    );

    return ThemeData(
      fontFamily: AppTextStyle.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.gold,
        primary: AppColor.gold,
        onPrimary: AppColor.surface,
        surface: AppColor.surface,
        error: AppColor.danger,
      ),
      scaffoldBackgroundColor: AppColor.surface,
      dividerTheme: const DividerThemeData(
        color: AppColor.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColor.gold,
          foregroundColor: AppColor.surface,
          disabledBackgroundColor: AppColor.surfaceMuted,
          disabledForegroundColor: AppColor.inkFaint,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.gold,
          side: const BorderSide(color: AppColor.gold),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.gold,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.surfaceSubtle,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: AppTextStyle.body.copyWith(color: AppColor.inkFaint),
        border: inputBorder(AppColor.borderStrong),
        enabledBorder: inputBorder(AppColor.borderStrong),
        focusedBorder: inputBorder(AppColor.gold),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
