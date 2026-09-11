import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_branch_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_capster_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_confirm_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_schedule_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_service_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_terms_step.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class BookingFlowPage extends StatelessWidget {
  const BookingFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingFlowProvider>(
      create: (BuildContext ctx) =>
          BookingFlowProvider(
            ctx.read<BookingRepository>(),
            ctx.read<AppCache>(),
            location: ctx.read<LocationService>(),
            lockDuration: ctx.read<DebugOverrides>().lockDuration,
          ),
      child: const _BookingFlowView(),
    );
  }
}

class _BookingFlowView extends StatelessWidget {
  const _BookingFlowView();

  static const int totalSteps = 5;

  static int _stepNumber(BookingStep step) => step.index;

  static String _heading(BookingStep step, AppLocalizations l10n) {
    switch (step) {
      case BookingStep.terms:
      case BookingStep.branch:
        return l10n.bookingBranchTitle;
      case BookingStep.schedule:
        return l10n.bookingScheduleTitle;
      case BookingStep.capster:
        return l10n.bookingBarberTitle;
      case BookingStep.service:
        return l10n.bookingServiceTitle;
      case BookingStep.confirm:
        return l10n.bookingConfirmTitle;
    }
  }

  static String _subtitle(BookingStep step, AppLocalizations l10n) {
    switch (step) {
      case BookingStep.terms:
      case BookingStep.branch:
        return l10n.bookingBranchSubtitle;
      case BookingStep.schedule:
        return l10n.bookingScheduleSubtitle;
      case BookingStep.capster:
        return l10n.bookingBarberSubtitle;
      case BookingStep.service:
        return l10n.bookingServiceSubtitle;
      case BookingStep.confirm:
        return l10n.bookingConfirmSubtitle;
    }
  }

  static String _cta(BookingStep step, AppLocalizations l10n) {
    switch (step) {
      case BookingStep.terms:
        return l10n.commonContinue;
      case BookingStep.branch:
        return l10n.bookingNextSchedule;
      case BookingStep.schedule:
        return l10n.bookingNextBarber;
      case BookingStep.capster:
        return l10n.bookingNextService;
      case BookingStep.service:
        return l10n.bookingNextConfirm;
      case BookingStep.confirm:
        return l10n.bookingConfirmCta;
    }
  }

  static String formatRemaining(Duration value) {
    final String m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleBack(BuildContext context, BookingFlowProvider p) async {
    final NavigatorState navigator = Navigator.of(context);

    if (p.needsCancelConfirm) {
      final bool confirmed = await _confirmCancel(context);
      if (!confirmed) return;
      await p.releaseLock();
    }

    if (!p.back()) navigator.pop();
  }

  Future<bool> _confirmCancel(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.bookingCancelTitle,
          style: AppTextStyle.titleMedium,
        ),
        content: Text(
          l10n.bookingCancelMessage,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.bookingCancelKeep,
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.bookingCancelConfirm,
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    return answer ?? false;
  }

  Future<void> _onCta(BuildContext context, BookingFlowProvider p) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);

    if (p.step != BookingStep.confirm) {
      await p.next();
      if (!context.mounted) return;

      if (p.lockError != null) {
        AppToast.show(context, message: p.lockError!.message(l10n));
      }
      return;
    }

    final bool ok = await p.submit();
    if (!context.mounted) return;

    if (!ok) {
      AppToast.show(
        context,
        message: p.submitError?.message(l10n) ?? l10n.exceptionDefault,
      );
      return;
    }

    navigator.pushReplacementNamed(
      AppRoute.bookingSuccess,
      arguments: p.result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final bool onTerms = p.step == BookingStep.terms;

    return LoadingOverlay(
      isVisible: p.submitting,
      child: PopScope(
        canPop: onTerms && !p.submitting,
        onPopInvokedWithResult: (bool didPop, Object? _) {
          if (!didPop) _handleBack(context, p);
        },
        child: Scaffold(
          backgroundColor: AppColor.surface,
          appBar: AppBar(
            backgroundColor: AppColor.surface,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => _handleBack(context, p),
              icon: Image.asset(
                AppAssets.backArrowIcon,
                width: 20,
                height: 16,
                fit: BoxFit.contain,
                color: AppColor.ink,
                filterQuality: FilterQuality.medium,
              ),
            ),
            title: Text(
              l10n.bookingTitle,
              style: AppTextStyle.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: <Widget>[
              if (p.hasLock)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _LockCountdown(remaining: p.lockRemaining),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!onTerms)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.bookingStepLabel(_stepNumber(p.step), totalSteps),
                          style: AppTextStyle.labelSmall.copyWith(
                            fontSize: 11,
                            color: AppColor.inkFaint,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _heading(p.step, l10n),
                          style: AppTextStyle.headlineMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(p.step, l10n),
                          style: AppTextStyle.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColor.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: p.step.index,
                    children: const <Widget>[
                      BookingTermsStep(),
                      BookingBranchStep(),
                      BookingScheduleStep(),
                      BookingCapsterStep(),
                      BookingServiceStep(),
                      BookingConfirmStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: BoxButton(
                    label: _cta(p.step, l10n),
                    isLoading: p.submitting || p.locking,
                    onPressed: p.canContinue
                        ? () => _onCta(context, p)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockCountdown extends StatelessWidget {
  const _LockCountdown({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool urgent = remaining.inSeconds <= 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: urgent
            ? AppColor.danger.withValues(alpha: 0.1)
            : AppColor.goldSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.bookingLockRemaining(
          _BookingFlowView.formatRemaining(remaining),
        ),
        style: AppTextStyle.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: urgent ? AppColor.danger : AppColor.ink,
        ),
      ),
    );
  }
}
