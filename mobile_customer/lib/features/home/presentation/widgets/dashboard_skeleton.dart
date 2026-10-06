import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_body.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/skeleton.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/dashboard_bottom_nav.dart';

/// Kerangka dashboard: bentuknya mengikuti isi asli supaya tidak lompat
/// waktu datanya masuk.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  static const double _pad = DashboardBody.sidePadding;

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          _pad,
          20,
          _pad,
          DashboardBottomNav.spaceOf(context),
        ),
        children: <Widget>[
          const SkeletonBox(height: 96, radius: 16),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                const Expanded(child: SkeletonBox(height: 78, radius: 14)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(height: 120, radius: 16),
          const SizedBox(height: 28),
          const SkeletonBox(width: 180, height: 20),
          const SizedBox(height: 12),
          const SkeletonBox(height: 140, radius: 16),
          const SizedBox(height: 28),
          const SkeletonBox(width: 150, height: 20),
          const SizedBox(height: 12),
          const SkeletonBox(height: 200, radius: 16),
        ],
      ),
    );
  }
}
