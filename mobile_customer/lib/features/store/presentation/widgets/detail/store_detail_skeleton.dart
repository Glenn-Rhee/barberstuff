import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/skeleton.dart';

/// Kerangka detail cabang: banner, judul, ringkasan, lalu tab.
class StoreDetailSkeleton extends StatelessWidget {
  const StoreDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonGroup(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonBox(height: 190, radius: 0),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonBox(width: 210, height: 22),
                  SizedBox(height: 10),
                  SkeletonBox(width: 260, height: 13),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 13),
                  SizedBox(height: 18),
                  SkeletonBox(height: 84, radius: 14),
                  SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      SkeletonBox(width: 96, height: 34, radius: 17),
                      SizedBox(width: 8),
                      SkeletonBox(width: 80, height: 34, radius: 17),
                      SizedBox(width: 8),
                      SkeletonBox(width: 72, height: 34, radius: 17),
                    ],
                  ),
                  SizedBox(height: 18),
                  SkeletonListTile(thumbSize: 56, lines: 2),
                  SizedBox(height: 10),
                  SkeletonListTile(thumbSize: 56, lines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
