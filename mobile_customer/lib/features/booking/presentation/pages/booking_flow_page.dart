import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/create_booking.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_store_slots.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/lock_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/release_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_lock.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_terms.dart';
import 'package:mobile_barberstuff/features/booking/presentation/models/booking_step_labels.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_lock_countdown.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_header.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_branch_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_capster_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_confirm_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_schedule_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_service_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_terms_step.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/dialogs/confirm_dialog.dart';
import 'package:mobile_barberstuff/shared/widgets/buttons/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/loading_overlay.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/app_back_bar.dart';
import 'package:provider/provider.dart';

class BookingFlowPage extends StatelessWidget {
  const BookingFlowPage({super.key, this.store});

  /// Cabang yang sudah dipilih dari detail cabang. null = pilih dari daftar.
  final StoreSummary? store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingFlowProvider>(
      create: (BuildContext ctx) => BookingFlowProvider(
        getStores: ctx.read<GetStores>(),
        getServices: ctx.read<GetStoreServices>(),
        getSlots: ctx.read<GetStoreSlots>(),
        lockSlot: ctx.read<LockBookingSlot>(),
        releaseSlot: ctx.read<ReleaseBookingSlot>(),
        createBooking: ctx.read<CreateBooking>(),
        getDraft: ctx.read<GetBookingDraft>(),
        saveTerms: ctx.read<SaveBookingTerms>(),
        saveLock: ctx.read<SaveBookingLock>(),
        location: ctx.read<LocationService>(),
        lockDuration: ctx.read<DebugOverrides>().lockDuration,
        store: store,
      ),
      child: const _BookingFlowView(),
    );
  }
}

class _BookingFlowView extends StatelessWidget {
  const _BookingFlowView();

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
          appBar: AppBackBar(
            title: l10n.bookingTitle,
            onBack: () => _handleBack(context, p),
            actions: <Widget>[
              if (p.hasLock)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: BookingLockCountdown(remaining: p.lockRemaining),
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
                    child: BookingStepHeader(
                      step: p.step,
                      stepNumber: p.stepNumber,
                      stepCount: p.stepCount,
                    ),
                  ),
                // Urutan anak harus sama dengan urutan enum BookingStep.
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
                    label: p.step.cta(l10n),
                    isLoading: p.submitting || p.locking,
                    onPressed: p.canContinue ? () => _onCta(context, p) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Aksi
  // ---------------------------------------------------------------------------

  Future<void> _handleBack(BuildContext context, BookingFlowProvider p) async {
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (p.needsCancelConfirm) {
      final bool confirmed = await showConfirmDialog(
        context,
        title: l10n.bookingCancelTitle,
        message: l10n.bookingCancelMessage,
        cancelLabel: l10n.bookingCancelKeep,
        confirmLabel: l10n.bookingCancelConfirm,
        confirmColor: AppColor.danger,
      );
      if (!confirmed) return;

      final bool released = await p.releaseLock();
      if (!released && context.mounted) {
        // Tanpa pesan ini user cuma melihat tombol Lanjut "diam" karena
        // server masih memegang kunci lama miliknya sendiri.
        AppToast.show(context, message: l10n.bookingReleaseFailed);
      }
    }

    if (!p.back()) navigator.pop();
  }

  Future<void> _onCta(BuildContext context, BookingFlowProvider p) async {
    if (p.step == BookingStep.confirm) {
      await _submit(context, p);
    } else {
      await _goNext(context, p);
    }
  }

  Future<void> _goNext(BuildContext context, BookingFlowProvider p) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (p.step == BookingStep.service && p.exceedsServerLimit) {
      AppToast.show(context, message: l10n.bookingServiceSingleOnly);
      return;
    }

    await p.next();
    if (!context.mounted) return;

    if (p.lockError != null) {
      AppToast.show(context, message: p.lockError!.message(l10n));
    }
  }

  Future<void> _submit(BuildContext context, BookingFlowProvider p) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);

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
      arguments: p.record,
    );
  }
}
