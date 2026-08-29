import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_text_link.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:mobile_barberstuff/shared/widgets/divider_or.dart';

class ChooseLoginPage extends StatelessWidget {
  const ChooseLoginPage({super.key});

  static const double _maxContentWidth = 420;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final double sidePadding = (screen.width * 0.07).clamp(20.0, 32.0);
    final double logoHeight = (screen.height * 0.24).clamp(120.0, 214.0);

    return Scaffold(
      backgroundColor: AppColor.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.logoLogin,
                          height: logoHeight,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screen.height * 0.03),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.chooseLoginWelcome,
                            maxLines: 1,
                            style: AppTextStyle.displaySmall,
                          ),
                        ),
                        const SizedBox(height: 28),
                        BoxButton(
                          variant: BoxButtonVariant.outlined,
                          iconPath: AppAssets.googleIcon,
                          label: l10n.chooseLoginGoogleText,
                          onPressed: () => showComingSoonDialog(context),
                        ),
                        const DividerOr(),
                        BoxButton(
                          label: l10n.chooseLoginWithPasswordText,
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoute.login),
                        ),
                        const SizedBox(height: 24),
                        AppTextLink(
                          message: l10n.chooseLoginTextMessage,
                          actionLabel: l10n.chooseLoginTextLink,
                          onPressed: () => {
                            Navigator.of(context).pushNamed(AppRoute.registerPage),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
