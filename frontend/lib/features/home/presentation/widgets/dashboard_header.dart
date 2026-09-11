import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/circle_icon_button.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.name,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.photoUrl,
  });

  static const double _avatarSize = 48;
  static const double _radius = 30;

  final String name;
  final String? photoUrl;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: AppColor.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColor.ink,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_radius),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Opacity(
                        opacity: name.isEmpty ? 0 : 1,
                        child: Text(
                          l10n.homeGreeting(name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.headlineMedium.copyWith(
                            color: AppColor.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        l10n.homeWelcomeBack,
                        style: AppTextStyle.labelMedium.copyWith(
                          color: AppColor.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleIconButton(
                  iconPath: AppAssets.bellDashboard,
                  onPressed: onNotificationTap,
                  size: _avatarSize,
                ),
                const SizedBox(width: 12),
                _ProfileAvatar(
                  photoUrl: photoUrl,
                  size: _avatarSize,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.size,
    required this.onTap,
  });

  final String? photoUrl;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.surface, width: 2),
        ),
        child: ClipOval(
          child: url == null
              ? const ColoredBox(
                  color: AppColor.inkSoft,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColor.surface,
                    size: 24,
                  ),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                      const ColoredBox(
                        color: AppColor.inkSoft,
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColor.surface,
                          size: 24,
                        ),
                      ),
                ),
        ),
      ),
    );
  }
}
