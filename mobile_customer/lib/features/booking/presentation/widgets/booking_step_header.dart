import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/presentation/models/booking_step_labels.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// "Langkah x dari y", judul langkah, lalu penjelasannya.
class BookingStepHeader extends StatelessWidget {
  const BookingStepHeader({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.stepCount,
  });

  final BookingStep step;
  final int stepNumber;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.bookingStepLabel(stepNumber, stepCount),
          style: AppTextStyle.labelSmall.copyWith(
            fontSize: 11,
            color: AppColor.inkFaint,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          step.heading(l10n),
          style: AppTextStyle.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          step.subtitle(l10n),
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12,
            color: AppColor.inkFaint,
          ),
        ),
      ],
    );
  }
}
