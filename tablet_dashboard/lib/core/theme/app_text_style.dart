import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTextStyle {
  const AppTextStyle._();

  static const String fontFamily = 'Poppins';

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColor.ink,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColor.ink,
  );
  static const TextStyle stat = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColor.ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColor.ink,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColor.ink,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColor.ink,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColor.inkSoft,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColor.inkSoft,
  );
}
