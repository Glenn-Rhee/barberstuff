import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingTermsStep extends StatelessWidget {
  const BookingTermsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.orangeLight, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  Expanded(
                    child: Text(
                      l10n.bookingTermsHeadline,
                      style: AppTextStyle.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.bookingTermsIntro, style: AppTextStyle.bodyLarge),
              const SizedBox(height: 18),
              Text(l10n.bookingTermsRulesLabel, style: AppTextStyle.titleSmall),
              const SizedBox(height: 10),
              for (final String rule in <String>[
                l10n.bookingTermsRule1,
                l10n.bookingTermsRule2,
                l10n.bookingTermsRule3,
                l10n.bookingTermsRule4,
              ])
                _Rule(text: rule),
              const SizedBox(height: 12),
              Text(l10n.bookingTermsOutro, style: AppTextStyle.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _AgreeCheckbox(
          value: p.agreed,
          label: l10n.bookingTermsAgree,
          onChanged: p.setAgreed,
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColor.customKeyProfileInfo2,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          Expanded(child: Text(text, style: AppTextStyle.bodyLarge)),
        ],
      ),
    );
  }
}

class _AgreeCheckbox extends StatelessWidget {
  const _AgreeCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColor.orangeLight : AppColor.surface,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: value ? AppColor.orangeLight : AppColor.inkSoft,
                  width: 1.6,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColor.surface,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyle.labelLarge)),
          ],
        ),
      ),
    );
  }
}
