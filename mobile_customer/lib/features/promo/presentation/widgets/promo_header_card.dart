import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/name_formatter.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Kartu hitam berisi sapaan, poin, dan lencana tier.
class PromoHeaderCard extends StatelessWidget {
  const PromoHeaderCard({super.key, required this.profile});

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(url: profile.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.homeGreeting(NameFormatter.firstName(profile.name)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleMedium.copyWith(
                        color: AppColor.surface,
                      ),
                    ),
                    Text(
                      l10n.homeWelcomeBack,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColor.inkSoft),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.goldDeep,
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  AppAssets.symbolStarDashboard,
                  fit: BoxFit.contain,
                  color: AppColor.surface,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.homePoints(formatPoints(profile.memberPoints)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColor.surface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.goldDeep,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tierLabel(profile.tier, l10n).toUpperCase(),
                  maxLines: 1,
                  style: AppTextStyle.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.surface,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  static const double _size = 42;

  final String? url;

  @override
  Widget build(BuildContext context) {
    const Widget fallback = ColoredBox(
      color: AppColor.inkSoft,
      child: Icon(Icons.person_rounded, size: 22, color: AppColor.surface),
    );

    return ClipOval(
      child: SizedBox(
        width: _size,
        height: _size,
        child: url == null
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    fallback,
              ),
      ),
    );
  }
}
