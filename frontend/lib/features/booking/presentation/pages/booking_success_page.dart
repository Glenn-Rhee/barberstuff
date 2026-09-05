import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_receipt.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_receipt_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

class BookingSuccessArgs {
  const BookingSuccessArgs({required this.receipt});

  final BookingReceipt receipt;
}

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key, required this.args});

  final BookingSuccessArgs args;

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
                            color: AppColor.orangeLight,
                          ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    l10n.bookingSuccessTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.headlineMedium.copyWith(
                      color: AppColor.orangeLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.bookingSuccessMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // BoxButton(
                  //   label: l10n.bookingSuccessReceipt,
                  //   radius: 14,
                  //   onPressed: () => Navigator.of(context).pushNamed(
                  //     AppRoute.bookingReceipt,
                  //     arguments: BookingReceiptArgs(receipt: args.receipt),
                  //   ),
                  // ),
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
      color: AppColor.orangeDashboard.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: BoxButton.minHeight),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.labelLarge.copyWith(color: AppColor.orangeDark),
          ),
        ),
      ),
    );
  }
}
