import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  static const double _badge = 40;

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
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(danger ? 12 : 0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: _badge,
                height: _badge,
                decoration: BoxDecoration(
                  color: danger
                      ? AppColor.surface
                      : AppColor.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
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
                  style: AppTextStyle.labelLarge.copyWith(color: tint),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                AppAssets.arrowFilledDashboard,
                width: 8,
                height: 16,
                fit: BoxFit.contain,
                color: danger ? AppColor.danger : AppColor.inkSoft,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
