import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

class VerifySuccessPage extends StatelessWidget {
  const VerifySuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 3),
                Image.asset(
                  AppAssets.checkVerification,
                  width: 160,
                  height: 160,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.verifySuccessTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.verifySuccessMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColor.inkSoft,
                  ),
                ),
                const SizedBox(height: 32),
                BoxButton(
                  label: l10n.verifySuccessButton,
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(
                        AppRoute.chooseLogin,
                        (Route<dynamic> r) => false,
                      ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
