import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_barber_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_branch_step.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_terms_step.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
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
    return step == BookingStep.barber
        ? l10n.bookingBarberTitle
        : l10n.bookingBranchTitle;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return PopScope(
      canPop: p.step == BookingStep.terms,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: BoxButton(
                  label: l10n.commonContinue,
                  onPressed: !p.canContinue
                      ? null
                      : () {
                          if (p.isLastStep) {
                            showComingSoonDialog(context);
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
    );
  }
}
