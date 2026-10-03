import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';

class TierTheme {
  const TierTheme({
    required this.base,
    required this.deep,
    required this.accent,
    required this.onAccent,
    required this.onCard,
    required this.sheen,
  });

  final Color base;
  final Color deep;
  final Color accent;
  final Color onAccent;
  final Color onCard;
  final Color sheen;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[base, deep],
  );

  static const TierTheme _silver = TierTheme(
    base: Color(0xFFDCE1E7),
    deep: Color(0xFFA9B2BD),
    accent: Color(0xFFC6CDD6),
    onAccent: Color(0xFF1B1E21),
    onCard: Color(0xFF1B1E21),
    sheen: Color(0xFFFFFFFF),
  );

  static const TierTheme _gold = TierTheme(
    base: Color(0xFFF7DA80),
    deep: Color(0xFFE8B845),
    accent: Color(0xFFEFC44F),
    onAccent: Color(0xFF1B1E21),
    onCard: Color(0xFF1B1E21),
    sheen: Color(0xFFFFFFFF),
  );

  static const TierTheme _platinum = TierTheme(
    base: Color(0xFFFDFEFF),
    deep: Color(0xFFD3DAE2),
    accent: Color(0xFFE9EEF4),
    onAccent: Color(0xFF1B1E21),
    onCard: Color(0xFF1B1E21),
    sheen: Color(0xFFFFFFFF),
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
