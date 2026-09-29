import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/login_with_email.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/reset_password.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/reset_password_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/remember_me_checkbox.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_field_decoration.dart';
import 'package:mobile_barberstuff/shared/widgets/app_text_field.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:mobile_barberstuff/shared/widgets/password_toggle.dart';
import 'package:provider/provider.dart';

class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email, required this.resetToken});

  /// Dipakai untuk login ulang otomatis setelah kata sandi diganti.
  final String email;
  final String resetToken;
}

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, required this.args});

  final ResetPasswordArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResetPasswordProvider>(
      create: (BuildContext ctx) => ResetPasswordProvider(
        ctx.read<ResetPassword>(),
        ctx.read<LoginWithEmail>(),
        ctx.read<AppSession>(),
        email: args.email,
        resetToken: args.resetToken,
      ),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView();

  Future<void> _submit(BuildContext context, ResetPasswordProvider p) async {
    FocusScope.of(context).unfocus();
    final ResetOutcome outcome = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    switch (outcome) {
      case ResetOutcome.failed:
        if (p.error != null) {
          AppToast.show(context, message: p.error!.message(l10n));
        }
      case ResetOutcome.signedIn:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.resetSuccess,
          (Route<dynamic> r) => r.isFirst,
        );
      case ResetOutcome.signedOut:
        AppToast.show(
          context,
          message: l10n.resetSignInFailed,
          type: AppToastType.info,
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoute.login, (Route<dynamic> r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final ResetPasswordProvider p = context.watch<ResetPasswordProvider>();

    return LoadingOverlay(
      isVisible: p.isLoading,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        appBar: AppBar(
          backgroundColor: AppColor.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: const BackButton(color: AppColor.ink),
          title: Text(l10n.resetPageBarText, style: AppTextStyle.titleMedium),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Form(
              key: p.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(l10n.resetHeadline, style: AppTextStyle.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    l10n.resetDescription,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 28),

                  AppTextField(
                    hint: l10n.resetPasswordHint,
                    iconPath: AppAssets.lockIcon,
                    controller: p.passwordController,
                    obscureText: p.obscurePassword,
                    validator: validators.password,
                    suffixIcon: PasswordToggle(
                      obscured: p.obscurePassword,
                      onPressed: p.toggleObscurePassword,
                    ),
                  ),
                  const SizedBox(height: AppField.gap),

                  AppTextField(
                    hint: l10n.resetConfirmHint,
                    iconPath: AppAssets.lockIcon,
                    controller: p.confirmController,
                    obscureText: p.obscureConfirm,
                    validator: (String? v) =>
                        validators.password(v) ??
                        (v != p.passwordController.text
                            ? l10n.validatorPasswordMismatch
                            : null),
                    suffixIcon: PasswordToggle(
                      obscured: p.obscureConfirm,
                      onPressed: p.toggleObscureConfirm,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RememberMeCheckbox(
                    value: p.rememberMe,
                    onChanged: p.setRememberMe,
                    label: l10n.loginRememberMe,
                  ),
                  const SizedBox(height: 28),

                  BoxButton(
                    label: l10n.resetSubmitButton,
                    isLoading: p.isLoading,
                    onPressed: p.isLoading || !p.isComplete
                        ? null
                        : () => _submit(context, p),
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
