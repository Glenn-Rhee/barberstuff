import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class AppField {
  const AppField._();

  static const double radius = 14;
  static const double iconSize = 20;
  static const double gap = 14;

  static Widget icon(String path, {required bool focused}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: Image.asset(
        path,
        width: iconSize,
        height: iconSize,
        filterQuality: FilterQuality.medium,
        color: focused ? AppColor.orange : AppColor.inkFaint,
      ),
    );
  }

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration decoration({
    required String hint,
    required bool focused,
    String? iconPath,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
      filled: true,
      fillColor: focused ? AppColor.cream : AppColor.surface,
      isDense: true,
      contentPadding: EdgeInsets.only(
        left: iconPath == null ? 16 : 0,
        right: 16,
        top: 18,
        bottom: 18,
      ),
      prefixIcon: iconPath == null ? null : icon(iconPath, focused: focused),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 0),
      border: _border(AppColor.border, 1),
      enabledBorder: _border(AppColor.border, 1),
      focusedBorder: _border(AppColor.orangeLight, 1.5),
      errorBorder: _border(AppColor.danger, 1),
      focusedErrorBorder: _border(AppColor.danger, 1.5),
      errorStyle: AppTextStyle.bodySmall.copyWith(color: AppColor.danger),
    );
  }
}
