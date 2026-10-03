import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

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
