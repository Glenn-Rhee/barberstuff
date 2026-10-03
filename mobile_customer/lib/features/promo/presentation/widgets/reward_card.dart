import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/presentation/widgets/points_tag.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.reward,
    required this.affordable,
    required this.onTap,
  });

  final RewardVoucher reward;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              reward.imageAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                  const ColoredBox(color: AppColor.border),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        reward.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyMedium.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      PointsTag(label: formatPoints(reward.points)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: affordable
                      ? AppColor.goldDeep
                      : AppColor.goldSoft.withValues(alpha: 0.4),
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      child: Text(
                        l10n.promoClaim,
                        style: AppTextStyle.titleSmall.copyWith(
                          fontSize: 13,
                          color: affordable
                              ? AppColor.surface
                              : AppColor.orangeDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
