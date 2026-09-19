import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColor.orangeLight,
      brightness: Brightness.light,
      primary: AppColor.orangeLight,
      onPrimary: AppColor.surface,
      surface: AppColor.surface,
      onSurface: AppColor.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyle.fontFamily,
      textTheme: AppTextStyle.textTheme,
      scaffoldBackgroundColor: AppColor.surface,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
