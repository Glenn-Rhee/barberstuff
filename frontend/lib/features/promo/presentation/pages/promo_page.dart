import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/promo/data/promo_catalog.dart';
import 'package:mobile_barberstuff/features/promo/domain/promo_content.dart';
import 'package:mobile_barberstuff/features/promo/presentation/widgets/promo_parts.dart';
import 'package:mobile_barberstuff/features/promo/presentation/widgets/reward_detail_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';

class PromoArgs {
  const PromoArgs({required this.profile});

  final CustomerProfile profile;
}

class PromoPage extends StatelessWidget {
  const PromoPage({super.key, required this.args});

  static const double _sidePadding = 20;

  final PromoArgs args;

  Future<void> _openReward(
    BuildContext context,
    RewardVoucher reward,
    int points,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? claimed = await showRewardDetailSheet(
      context,
      reward: reward,
      ownedPoints: points,
    );
    if (!context.mounted) return;

    AppToast.show(
      context,
      message: claimed == true ? l10n.promoClaimed : l10n.promoNotEnoughPoints,
      type: claimed == true ? AppToastType.success : AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Profil hidup dari provider supaya tarik-ulang benar-benar mengubah
    // poin dan tier di layar; args cuma dipakai sebagai nilai awal.
    final ProfileProvider profileProvider = context.watch<ProfileProvider>();
    final CustomerProfile profile = profileProvider.profile ?? args.profile;

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Image.asset(
            AppAssets.backArrowIcon,
            width: 20,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.ink,
            filterQuality: FilterQuality.medium,
          ),
        ),
        title: Text(
          l10n.promoTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: profileProvider.load,
          color: AppColor.goldDeep,
          child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(_sidePadding, 4, _sidePadding, 28),
          children: <Widget>[
            PromoHeaderCard(profile: profile),

            const SizedBox(height: 22),
            _SectionHead(title: l10n.promoGradeTitle, action: l10n.promoTerms),
            const SizedBox(height: 12),
            GradeStepRow(grades: PromoCatalog.grades, current: profile.tier),

            const SizedBox(height: 20),
            for (final GradeBenefit benefit
                in PromoCatalog.benefits) ...<Widget>[
              GradeBenefitTile(benefit: benefit),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 12),
            _SectionHead(
              title: l10n.promoSectionTitle,
              subtitle: l10n.promoSectionSubtitle,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: PromoCatalog.banners.length,
                separatorBuilder: (BuildContext _, int _) =>
                    const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) =>
                    PromoBannerCard(banner: PromoCatalog.banners[index]),
              ),
            ),

            const SizedBox(height: 26),
            _SectionHead(
              title: l10n.promoRedeemTitle,
              subtitle: l10n.promoRedeemSubtitle,
            ),
            const SizedBox(height: 12),
            for (final RewardVoucher reward
                in PromoCatalog.rewards) ...<Widget>[
              RewardCard(
                reward: reward,
                affordable: reward.affordableBy(profile.memberPoints),
                onTap: () => _openReward(context, reward, profile.memberPoints),
              ),
              const SizedBox(height: 14),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final String? label = action;
    final String? caption = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.titleMedium.copyWith(fontSize: 16),
              ),
            ),
            if (label != null)
              Text(
                label,
                style: AppTextStyle.titleSmall.copyWith(
                  fontSize: 12,
                  color: AppColor.goldDeep,
                ),
              ),
          ],
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            caption,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 12,
              color: AppColor.inkFaint,
            ),
          ),
        ],
      ],
    );
  }
}
