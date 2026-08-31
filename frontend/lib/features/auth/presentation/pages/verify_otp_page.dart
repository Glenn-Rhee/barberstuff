import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/verify_otp_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/otp_field.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';

class VerifyOtpArgs {
  const VerifyOtpArgs({required this.userId, required this.registerRequest});

  final String userId;
  final RegisterRequestApi registerRequest;
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

    if (ok) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoute.verifySuccess, (Route<dynamic> r) => r.isFirst);
    } else if (p.errorMessage != null) {
      AppToast.show(context, message: p.errorMessage!);
    }
  }

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
    } else if (p.errorMessage != null) {
      AppToast.show(context, message: p.errorMessage!);
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
        title: Text(l10n.verifyPageBarText, style: AppTextStyle.titleMedium),
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
    required this.secondsLeft,
  });

  final VoidCallback onPressed;
  final bool canResend;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (secondsLeft > 0) {
      return Text(
        l10n.verifyResendCountdown(secondsLeft),
        textAlign: TextAlign.center,
        style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          l10n.verifyResendQuestion,
          style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
        ),
        const SizedBox(width: 4),
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
