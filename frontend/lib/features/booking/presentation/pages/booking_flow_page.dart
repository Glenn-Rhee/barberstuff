import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_barber_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_branch_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_schedule_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_service_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_terms_step.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_receipt.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_success_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class BookingFlowPage extends StatelessWidget {
  const BookingFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingFlowProvider>(
      create: (BuildContext ctx) =>
          BookingFlowProvider(ctx.read<BookingCatalog>()),
      child: const _BookingFlowView(),
    );
  }
}

class _BookingFlowView extends StatelessWidget {
  const _BookingFlowView();

  String _title(BookingStep step, AppLocalizations l10n) {
    switch (step) {
      case BookingStep.terms:
      case BookingStep.branch:
        return l10n.bookingBranchTitle;
      case BookingStep.barber:
        return l10n.bookingBarberTitle;
      case BookingStep.schedule:
        return l10n.bookingScheduleTitle;
      case BookingStep.service:
        return l10n.bookingServiceTitle;
    }
  }

  // Future<void> _submit(BuildContext context, BookingFlowProvider p) async {
  //   final NavigatorState navigator = Navigator.of(context);
  //   final CustomerProfileSummary customer = _customerOf(context);

  //   await p.submit();
  //   if (p.orderId == null) return;

  //   navigator.pushReplacementNamed(
  //     AppRoute.bookingSuccess,
  //     arguments: BookingSuccessArgs(
  //       receipt: BookingReceipt(
  //         orderId: p.orderId!,
  //         store: p.selectedStore!,
  //         capster: p.selectedCapster!,
  //         date: p.date!,
  //         time: p.time!,
  //         services: p.selectedServices,
  //         customerName: customer.name,
  //         customerPhone: customer.phone,
  //       ),
  //     ),
  //   );
  // }

  CustomerProfileSummary _customerOf(BuildContext context) {
    try {
      final profile = context.read<ProfileProvider>().profile;
      if (profile != null) {
        return CustomerProfileSummary(profile.name, profile.phoneNumber);
      }
    } on ProviderNotFoundException {
      // Alur booking bisa dibuka tanpa shell, misalnya di widget test.
    }
    return const CustomerProfileSummary('-', '');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return LoadingOverlay(
      isVisible: p.submitting,
      child: PopScope(
        canPop: p.step == BookingStep.terms && !p.submitting,
        onPopInvokedWithResult: (bool didPop, Object? _) {
          if (!didPop) p.back();
        },
        child: Scaffold(
          backgroundColor: AppColor.surface,
          appBar: AppBar(
            backgroundColor: AppColor.surface,
            elevation: 0,
            titleSpacing: 0,
            leading: BackButton(
              color: AppColor.ink,
              onPressed: () {
                if (!p.back()) Navigator.of(context).pop();
              },
            ),
            title: Text(
              _title(p.step, l10n),
              style: AppTextStyle.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: IndexedStack(
                    index: p.step.index,
                    children: <Widget>[
                      const BookingTermsStep(),
                      BookingBranchStep(
                        onViewStore: (_) => showComingSoonDialog(context),
                      ),
                      const BookingBarberStep(),
                      const BookingScheduleStep(),
                      const BookingServiceStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: BoxButton(
                    label: l10n.commonContinue,
                    isLoading: p.submitting,
                    onPressed: !p.canContinue
                        ? null
                        : () {
                            if (p.isLastStep) {
                              // _submit(context, p);
                              return;
                            }
                            p.next();
                          },
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

class CustomerProfileSummary {
  const CustomerProfileSummary(this.name, this.phone);

  final String name;
  final String phone;
}
