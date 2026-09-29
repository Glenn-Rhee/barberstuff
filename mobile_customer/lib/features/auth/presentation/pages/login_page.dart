import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/login_with_email.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/login_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/google_sign_in_scope.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/remember_me_checkbox.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_field_decoration.dart';
import 'package:mobile_barberstuff/shared/widgets/app_text_field.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/circle_icon_button.dart';
import 'package:mobile_barberstuff/shared/widgets/divider_or.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:mobile_barberstuff/shared/widgets/password_toggle.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginProvider>(
      create: (BuildContext ctx) =>
          LoginProvider(ctx.read<LoginWithEmail>(), ctx.read<AppSession>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  Future<void> _submit(BuildContext context, LoginProvider p) async {
    FocusScope.of(context).unfocus();
    final bool ok = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ok) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoute.home, (Route<dynamic> r) => false);
    } else if (p.error != null) {
      AppToast.show(context, message: p.error!.message(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final LoginProvider p = context.watch<LoginProvider>();

    return GoogleSignInScope(
      builder: (bool googleLoading, VoidCallback onGooglePressed) =>
          LoadingOverlay(
            isVisible: p.isLoading || googleLoading,
            child: Scaffold(
              backgroundColor: AppColor.surface,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: AppColor.ink),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Form(
                    key: p.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          l10n.loginHeadline,
                          style: AppTextStyle.headlineMedium,
                        ),
                        const SizedBox(height: 32),

                        AppTextField(
                          hint: l10n.loginEmailHint,
                          iconPath: AppAssets.mailIcon,
                          controller: p.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validators.email,
                        ),
                        const SizedBox(height: AppField.gap),

                        AppTextField(
                          hint: l10n.loginPasswordHint,
                          iconPath: AppAssets.lockIcon,
                          controller: p.passwordController,
                          obscureText: p.obscurePassword,
                          validator: validators.password,
                          suffixIcon: PasswordToggle(
                            obscured: p.obscurePassword,
                            onPressed: p.toggleObscurePassword,
                          ),
                        ),
                        const SizedBox(height: 12),

                        RememberMeCheckbox(
                          value: p.rememberMe,
                          onChanged: p.setRememberMe,
                          label: l10n.loginRememberMe,
                        ),
                        const SizedBox(height: 20),

                        BoxButton(
                          label: l10n.loginSubmitButton,
                          isLoading: p.isLoading,
                          onPressed: p.isLoading || !p.isComplete
                              ? null
                              : () => _submit(context, p),
                        ),

                        const DividerOr(),

                        Center(
                          child: CircleIconButton(
                            iconPath: AppAssets.googleIcon,
                            tooltip: l10n.loginWithGoogle,
                            onPressed: onGooglePressed,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              l10n.loginForgotQuestion,
                              style: AppTextStyle.bodySmall.copyWith(
                                color: AppColor.inkFaint,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoute.forgotPassword),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  l10n.loginForgotAction,
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: AppColor.orangeLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
