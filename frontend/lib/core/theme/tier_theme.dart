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

  static const TierTheme _lite = TierTheme(
    base: Color(0xFF2E3338),
    deep: Color(0xFF15181B),
    accent: Color(0xFFC3CCD6),
    onAccent: Color(0xFF15181B),
  );

  static const TierTheme _bestie = TierTheme(
    base: Color(0xFF4A3524),
    deep: Color(0xFF1E140C),
    accent: Color(0xFFD79A6A),
    onAccent: Color(0xFF1E140C),
  );

  static const TierTheme _royal = TierTheme(
    base: Color(0xFF3B2F14),
    deep: Color(0xFF171206),
    accent: Color(0xFFFECC67),
    onAccent: Color(0xFF171206),
  );

  static const TierTheme _crazy = TierTheme(
    base: Color(0xFF352247),
    deep: Color(0xFF150D1E),
    accent: Color(0xFFC79BEC),
    onAccent: Color(0xFF150D1E),
  );

  static TierTheme of(MemberTier tier) {
    switch (tier) {
      case MemberTier.newbie:
        return _lite;
      case MemberTier.bestie:
        return _bestie;
      case MemberTier.royal:
        return _royal;
      case MemberTier.crazy:
        return _crazy;
    }
  }
}
