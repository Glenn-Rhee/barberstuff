import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/presentation/widgets/points_tag.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/buttons/box_button.dart';

/// Mengembalikan true kalau pengguna menekan klaim.
Future<bool?> showRewardDetailSheet(
  BuildContext context, {
  required RewardVoucher reward,
  required int ownedPoints,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) =>
        _RewardDetailSheet(reward: reward, ownedPoints: ownedPoints),
  );
}

class _RewardDetailSheet extends StatelessWidget {
  const _RewardDetailSheet({required this.reward, required this.ownedPoints});

  final RewardVoucher reward;
  final int ownedPoints;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool affordable = reward.affordableBy(ownedPoints);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  reward.imageAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                      const ColoredBox(color: AppColor.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              reward.title,
              style: AppTextStyle.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: PointsTag(
                label: l10n.promoPoints(formatPoints(reward.points)),
                fontSize: 14,
                iconSize: 18,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.promoAboutVoucher,
              style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              textAlign: TextAlign.justify,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 12.5,
                height: 1.7,
                color: AppColor.inkSoft,
              ),
            ),
            const SizedBox(height: 22),
            if (affordable)
              BoxButton(
                label: l10n.promoClaimReward,
                onPressed: () => Navigator.of(context).pop(true),
              )
            else
              _PointProgress(owned: ownedPoints, needed: reward.points),
          ],
        ),
      ),
    );
  }
}

/// Ditampilkan saat poin belum cukup, menggantikan tombol klaim.
class _PointProgress extends StatelessWidget {
  const _PointProgress({required this.owned, required this.needed});

  final int owned;
  final int needed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double value = needed == 0 ? 0 : (owned / needed).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          l10n.promoProgress(formatPoints(owned), formatPoints(needed)),
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 11.5,
            color: AppColor.inkSoft,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 14,
            backgroundColor: AppColor.goldSoft.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColor.orange),
          ),
        ),
      ],
    );
  }
}
