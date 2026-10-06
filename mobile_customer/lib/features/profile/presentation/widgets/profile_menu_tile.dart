import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// Satu baris menu. Rangka kartu dipegang [ProfileMenuGroup].
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  static const double _badge = 38;

  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color tint = danger ? AppColor.danger : AppColor.ink;

    return Material(
      color: danger
          ? AppColor.danger.withValues(alpha: 0.07)
          : AppColor.surface,
      child: InkWell(
        onTap: onTap,
        splashColor: tint.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: <Widget>[
              Container(
                width: _badge,
                height: _badge,
                decoration: BoxDecoration(
                  color: danger
                      ? AppColor.surface
                      : AppColor.border.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 19,
                    height: 19,
                    fit: BoxFit.contain,
                    color: tint,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 15,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                AppAssets.arrowFilledDashboard,
                width: 8,
                height: 16,
                fit: BoxFit.contain,
                color: danger ? AppColor.danger : AppColor.inkFaint,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Membungkus tile jadi satu kartu dempet dengan garis pemisah.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, required this.children});

  static const double _radius = 10;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColor.ink, width: 0),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColor.border),
            children[i],
          ],
        ],
      ),
    );
  }
}
