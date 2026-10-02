import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/buttons/box_button.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key, required this.record});

  final BookingRecord record;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      AppAssets.checkVerification,
                      width: 132,
                      height: 132,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 132,
                            color: AppColor.goldDeep,
                          ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    l10n.bookingSuccessTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.headlineMedium.copyWith(
                      color: AppColor.goldDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bookingSuccessMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 28),
                  BoxButton(
                    label: l10n.bookingSuccessReceipt,
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoute.bookingReceipt, arguments: record),
                  ),
                  const SizedBox(height: 12),
                  _SoftButton(
                    label: l10n.bookingSuccessHome,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoute.home,
                          (Route<dynamic> r) => false,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.goldSoft.withValues(alpha: 0.45),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: BoxButton.minHeight,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.labelLarge.copyWith(
              color: AppColor.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
