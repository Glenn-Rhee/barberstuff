import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/name_formatter.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/features/promo/domain/promo_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

String formatPoints(int value) {
  final String digits = value.abs().toString();
  final StringBuffer out = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }

  return out.toString();
}

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

/// Tiga kartu tingkat plus indikator langkah di bawahnya.
class GradeStepRow extends StatelessWidget {
  const GradeStepRow({super.key, required this.grades, required this.current});

  final List<GradeStep> grades;
  final MemberTier current;

  int get _currentIndex => grades
      .indexWhere((GradeStep g) => g.tier == current)
      .clamp(0, grades.length - 1);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        // Tinggi kartu disamakan tanpa nilai tetap, supaya aman di skala teks besar.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < grades.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _GradeCard(
                    grade: grades[i],
                    active: i == _currentIndex,
                    xpLabel: l10n.promoXp(formatPoints(grades[i].xp)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _StepDots(count: grades.length, currentIndex: _currentIndex),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.grade,
    required this.active,
    required this.xpLabel,
  });

  final GradeStep grade;
  final bool active;
  final String xpLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: active
            ? AppColor.goldSoft.withValues(alpha: 0.25)
            : AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppColor.goldDeep : AppColor.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColor.goldSoft.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.goldDeep),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              grade.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            grade.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              xpLabel,
              maxLines: 1,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 11,
                color: AppColor.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.currentIndex});

  static const double _size = 30;

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++) ...<Widget>[
          if (i > 0)
            SizedBox(
              width: 44,
              child: Divider(
                thickness: 1.5,
                color: i <= currentIndex ? AppColor.goldDeep : AppColor.border,
              ),
            ),
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= currentIndex ? AppColor.goldDeep : AppColor.border,
            ),
            child: Center(
              child: i <= currentIndex
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColor.surface,
                    )
                  : Text(
                      '${i + 1}',
                      style: AppTextStyle.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.inkSoft,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class GradeBenefitTile extends StatelessWidget {
  const GradeBenefitTile({super.key, required this.benefit});

  final GradeBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.goldSoft.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(9),
            child: Image.asset(
              benefit.iconAsset,
              fit: BoxFit.contain,
              color: AppColor.orangeDark,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  benefit.title,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  benefit.description,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 11.5,
                    height: 1.5,
                    color: AppColor.inkSoft,
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

class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    // Ikut melebar saat skala teks dinaikkan supaya teks tidak terpotong.
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return Container(
      width: 170 * scale,
      padding: const EdgeInsets.all(14),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: banner.highlighted ? Colors.transparent : AppColor.border,
        ),
        gradient: banner.highlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColor.orangeDashboard, AppColor.goldSoft],
              )
            : null,
        color: banner.highlighted ? null : AppColor.surface,
      ),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                banner.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.titleMedium.copyWith(
                  fontSize: 17,
                  color: AppColor.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                banner.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.ink,
                ),
              ),
              const Spacer(),
              Text(
                banner.footnote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: banner.highlighted
                      ? FontWeight.w400
                      : FontWeight.w700,
                  color: banner.highlighted
                      ? AppColor.inkSoft
                      : AppColor.orangeLight,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                banner.iconAsset,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
                color: AppColor.ink,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PointsTag extends StatelessWidget {
  const PointsTag({
    super.key,
    required this.label,
    this.fontSize = 13,
    this.iconSize = 16,
  });

  final String label;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          AppAssets.pointPromo,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyle.titleSmall.copyWith(
            fontSize: fontSize,
            color: AppColor.orangeLight,
          ),
        ),
      ],
    );
  }
}

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
