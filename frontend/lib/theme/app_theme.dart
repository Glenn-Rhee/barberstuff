import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_text_style.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColor.gold,
      brightness: Brightness.light,
      primary: AppColor.gold,
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
