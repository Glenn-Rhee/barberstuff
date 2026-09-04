import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/verify_otp_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/provider/forgot_password_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordProvider>(
      create: (BuildContext ctx) =>
          ForgotPasswordProvider(ctx.read<AuthRepository>()),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  Future<void> _submit(BuildContext context, ForgotPasswordProvider p) async {
    FocusScope.of(context).unfocus();
    final bool ok = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ok) {
      if (p.error != null) {
        AppToast.show(context, message: p.error!.message(l10n));
      }
      return;
    }

    AppToast.show(
      context,
      message: l10n.registerOtpSentMessage,
      type: AppToastType.success,
    );
    Navigator.of(context).pushNamed(
      AppRoute.verifyOtp,
      arguments: VerifyOtpArgs(
        userId: p.result!.userId,
        email: p.email,
        purpose: OtpPurpose.forgotPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final ForgotPasswordProvider p = context.watch<ForgotPasswordProvider>();

    return LoadingOverlay(
      isVisible: p.isLoading,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        appBar: AppBar(
          backgroundColor: AppColor.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: const BackButton(color: AppColor.ink),
          title: Text(l10n.forgotPageBarText, style: AppTextStyle.titleMedium),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: p.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 24),
                  Image.asset(
                    AppAssets.forgotPassword,
                    height: 170,
                    filterQuality: FilterQuality.medium,
                  ),
                  const SizedBox(height: 32),

                  Text(
                    l10n.forgotHeadline,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.forgotDescription,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 28),

                  AppTextField(
                    hint: l10n.loginEmailHint,
                    iconPath: AppAssets.mailIcon,
                    controller: p.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validators.email,
                  ),
                  const SizedBox(height: 28),

                  BoxButton(
                    label: l10n.forgotSubmitButton,
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
