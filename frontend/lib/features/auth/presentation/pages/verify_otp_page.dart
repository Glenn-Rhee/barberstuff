import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/verify_otp_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/otp_field.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/reset_password_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';

class VerifyOtpArgs {
  const VerifyOtpArgs({
    required this.userId,
    required this.email,
    this.purpose = OtpPurpose.register,
    this.registerRequest,
  });

  final String userId;
  final String email;
  final OtpPurpose purpose;

  /// Hanya dipakai alur registrasi, untuk mengulang POST /auth/register saat
  /// pengguna menekan "kirim ulang kode".
  final RegisterRequestApi? registerRequest;
}

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({super.key, required this.args});

  final VerifyOtpArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VerifyOtpProvider>(
      create: (BuildContext ctx) => VerifyOtpProvider(
        ctx.read<AuthRepository>(),
        userId: args.userId,
        email: args.email,
        purpose: args.purpose,
        registerRequest: args.registerRequest,
      ),
      child: const _VerifyOtpView(),
    );
  }
}

class _VerifyOtpView extends StatelessWidget {
  const _VerifyOtpView();

  Future<void> _submit(BuildContext context, VerifyOtpProvider p) async {
    FocusScope.of(context).unfocus();
    final bool ok = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ok) {
      if (p.error != null) {
        AppToast.show(context, message: _errorText(p, l10n));
      }
      return;
    }

    if (p.purpose == OtpPurpose.forgotPassword) {
      Navigator.of(context).pushNamed(
        AppRoute.resetPassword,
        arguments: ResetPasswordArgs(
          email: p.email,
          resetToken: p.resetToken ?? '',
        ),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoute.verifySuccess,
      (Route<dynamic> r) => r.isFirst,
    );
  }

  String _errorText(VerifyOtpProvider p, AppLocalizations l10n) =>
      p.isAttemptExhausted
      ? l10n.verifyAttemptExhausted
      : p.error!.message(l10n);

  Future<void> _resend(BuildContext context, VerifyOtpProvider p) async {
    final bool ok = await p.resend();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ok) {
      AppToast.show(
        context,
        message: l10n.verifyResendSuccess,
        type: AppToastType.success,
      );
    } else if (p.error != null) {
      AppToast.show(context, message: _errorText(p, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final VerifyOtpProvider p = context.watch<VerifyOtpProvider>();

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          p.purpose == OtpPurpose.forgotPassword
              ? l10n.forgotPageBarText
              : l10n.verifyPageBarText,
          style: AppTextStyle.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              Image.asset(
                AppAssets.emailVerification,
                width: 140,
                height: 140,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 32),

              Text(
                l10n.verifyHeadline,
                textAlign: TextAlign.center,
                style: AppTextStyle.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.verifyDescription(p.email),
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkSoft),
              ),
              const SizedBox(height: 28),

              OtpField(
                controllers: p.controllers,
                focusNodes: p.focusNodes,
                hasError: p.hasError,
                enabled: !p.isLoading,
                onCompleted: () => _submit(context, p),
              ),
              const SizedBox(height: 28),

              BoxButton(
                label: l10n.verifySubmitButton,
                isLoading: p.isLoading,
                onPressed: p.isLoading || !p.isComplete
                    ? null
                    : () => _submit(context, p),
              ),
              const SizedBox(height: 24),

              _ResendRow(
                onPressed: () => _resend(context, p),
                canResend: p.canResend,
                isResending: p.isResending,
                secondsLeft: p.secondsLeft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.onPressed,
    required this.canResend,
    required this.isResending,
    required this.secondsLeft,
  });

  final VoidCallback onPressed;
  final bool canResend;
  final bool isResending;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (secondsLeft > 0) {
      final String seconds = (secondsLeft % 60).toString().padLeft(2, '0');

      return Text(
        l10n.verifyResendCountdown('${secondsLeft ~/ 60}:$seconds'),
        textAlign: TextAlign.center,
        style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: <Widget>[
        Text(
          l10n.verifyResendQuestion,
          style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
        ),
        if (isResending)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.orangeLight,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: canResend ? onPressed : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                l10n.verifyResendAction,
                style: AppTextStyle.bodySmall.copyWith(
                  color: canResend ? AppColor.orangeLight : AppColor.inkFaint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
