import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Kartu putih bersudut bulat dengan border tipis, dasar hampir semua panel
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
      ),
      child: child,
    );
  }
}
