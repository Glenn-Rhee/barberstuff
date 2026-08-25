import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  static const Color gold = Color(0xFFDD9E35);
  static const Color goldLight = Color(0xFFEFBE71);
  static const Color goldDark = Color(0xFFC1841F);

  static const Color ink = Color(0xFF161616);
  static const Color inkSoft = Color(0xFF6B6B6B);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFAF3E7);
  static const Color pattern = Color(0xFFF6EDDC);
  static const Color shimmer = Color(0xFFFFFFFF);
  static const Color dotIdle = Color(0xFFE2E2E2);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[goldLight, gold, goldDark],
  );
}
