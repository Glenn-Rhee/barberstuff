import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/skeleton.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/dashboard_bottom_nav.dart';

/// Kerangka halaman profil: foto bulat, nama, tier, lalu daftar menu.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  static const double _sidePadding = 20;

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          _sidePadding,
          24,
          _sidePadding,
          DashboardBottomNav.spaceOf(context),
        ),
        children: <Widget>[
          const Center(child: SkeletonBox.circle(size: 96)),
          const SizedBox(height: 18),
          const Center(child: SkeletonBox(width: 170, height: 20)),
          const SizedBox(height: 10),
          const Center(child: SkeletonBox(width: 210, height: 13)),
          const SizedBox(height: 8),
          const Center(child: SkeletonBox(width: 150, height: 13)),
          const SizedBox(height: 18),
          const Center(child: SkeletonBox(width: 240, height: 44, radius: 22)),
          const SizedBox(height: 26),
          for (int i = 0; i < 7; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const SkeletonBox(width: 44, height: 44, radius: 12),
                const SizedBox(width: 14),
                SkeletonBox(width: 120 + (i % 3) * 40, height: 15),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
