import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/name_formatter.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/circle_icon_button.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.name,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.photoUrl,
    this.collapsed = false,
  });

  static const Duration collapseDuration = Duration(milliseconds: 240);

  static const double _avatarSize = 48;
  static const double _avatarSizeMin = 36;
  static const double _radius = 30;
  static const double _radiusMin = 20;
  static const double _greetingSize = 24;
  static const double _greetingSizeMin = 17;

  final String name;
  final String? photoUrl;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String greetingName = NameFormatter.firstName(name);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: collapsed ? 1 : 0),
      duration: collapseDuration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) {
        final double avatar = lerpDouble(_avatarSize, _avatarSizeMin, t)!;

        return ColoredBox(
          color: AppColor.surface,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.ink,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(lerpDouble(_radius, _radiusMin, t)!),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  lerpDouble(14, 8, t)!,
                  24,
                  lerpDouble(28, 12, t)!,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Opacity(
                            opacity: greetingName.isEmpty ? 0 : 1,
                            child: Text(
                              l10n.homeGreeting(greetingName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.headlineMedium.copyWith(
                                fontSize: lerpDouble(
                                  _greetingSize,
                                  _greetingSizeMin,
                                  t,
                                ),
                                color: AppColor.surface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Subjudul ikut mengecil sampai hilang saat menyusut.
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topLeft,
                              heightFactor: 1 - t,
                              child: Opacity(
                                opacity: 1 - t,
                                child: Text(
                                  l10n.homeWelcomeBack,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.labelMedium.copyWith(
                                    color: AppColor.inkFaint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleIconButton(
                      iconPath: AppAssets.bellDashboard,
                      onPressed: onNotificationTap,
                      size: avatar,
                    ),
                    const SizedBox(width: 12),
                    _ProfileAvatar(
                      photoUrl: photoUrl,
                      size: avatar,
                      onTap: onProfileTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

    final Widget fallback = ColoredBox(
      color: AppColor.inkSoft,
      child: Icon(
        Icons.person_rounded,
        color: AppColor.surface,
        size: size * 0.5,
      ),
    );

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
              ? fallback
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                      fallback,
                ),
        ),
      ),
    );
  }
}
