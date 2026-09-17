import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

/// Keuntungan yang berlaku di satu tingkat keanggotaan.
class GradeBenefit {
  const GradeBenefit({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;
}

/// Satu tingkat pada baris grade di atas daftar keuntungan.
class GradeStep {
  const GradeStep({
    required this.tier,
    required this.label,
    required this.xp,
    required this.imageAsset,
  });

  final MemberTier tier;
  final String label;
  final int xp;
  final String imageAsset;
}

class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.footnote,
    required this.iconAsset,
    this.highlighted = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String footnote;
  final String iconAsset;
  final bool highlighted;
}

class RewardVoucher {
  const RewardVoucher({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final String imageAsset;

  bool affordableBy(int owned) => owned >= points;
}
