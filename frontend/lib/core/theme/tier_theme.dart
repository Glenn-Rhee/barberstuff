import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

class TierTheme {
  const TierTheme({
    required this.base,
    required this.deep,
    required this.accent,
    required this.onAccent,
  });

  final Color base;
  final Color deep;
  final Color accent;
  final Color onAccent;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[base, deep],
  );

  static const TierTheme _silver = TierTheme(
    base: Color(0xFF3A4046),
    deep: Color(0xFF16191C),
    accent: Color(0xFFC3CCD6),
    onAccent: Color(0xFF16191C),
  );

  static const TierTheme _gold = TierTheme(
    base: Color(0xFF3B2F14),
    deep: Color(0xFF171206),
    accent: Color(0xFFFECC67),
    onAccent: Color(0xFF171206),
  );

  static const TierTheme _platinum = TierTheme(
    base: Color(0xFF2B3440),
    deep: Color(0xFF0E1318),
    accent: Color(0xFFE6ECF2),
    onAccent: Color(0xFF0E1318),
  );

  static TierTheme of(MemberTier tier) {
    switch (tier) {
      case MemberTier.silver:
        return _silver;
      case MemberTier.gold:
        return _gold;
      case MemberTier.platinum:
        return _platinum;
    }
  }
}
