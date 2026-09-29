import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/history_provider.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/history_card.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/review_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_search_bar.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/dashboard_bottom_nav.dart';
import 'package:mobile_barberstuff/shared/widgets/filter_chip_bar.dart';
import 'package:mobile_barberstuff/shared/widgets/skeleton.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryProvider>(
      create: (BuildContext ctx) =>
          HistoryProvider(ctx.read<CustomerBookingsProvider>()),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  static const double sidePadding = 20;

  String _tabLabel(HistoryTab tab, AppLocalizations l10n) {
    switch (tab) {
      case HistoryTab.upcoming:
        return l10n.historyTabUpcoming;
      case HistoryTab.done:
        return l10n.historyTabDone;
      case HistoryTab.canceled:
        return l10n.historyTabCanceled;
    }
  }

  Future<void> _openReview(
    BuildContext context,
    HistoryProvider p,
    BookingHistory item,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final ReviewDraft? draft = await showReviewSheet(
      context,
      readOnly: item.isReviewed,
      initial: context.read<CustomerBookingsProvider>().reviewOf(item.id),
    );
    if (draft == null || !context.mounted) return;

    final bool ok = await p.submitReview(item.id, draft);
    if (!context.mounted) return;

    if (!ok) {
      if (p.submitError != null) {
        AppToast.show(context, message: p.submitError!.message(l10n));
      }
      return;
    }

    AppToast.show(context, message: l10n.reviewThanks);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final HistoryProvider p = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColor.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                sidePadding,
                18,
                sidePadding,
                14,
              ),
              child: Text(
                l10n.historyTitle,
                style: AppTextStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                sidePadding,
                0,
                sidePadding,
                12,
              ),
              child: AppSearchBar(
                controller: p.searchController,
                hint: l10n.bookingSearchHint,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: FilterChipBar(
                labels: <String>[
                  for (final HistoryTab tab in HistoryTab.values)
                    _tabLabel(tab, l10n),
                ],
                activeIndex: HistoryTab.values.indexOf(p.tab),
                onSelect: (int i) => p.setTab(HistoryTab.values[i]),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: p.isLoading && p.items.isEmpty
                  ? SkeletonList(
                      itemCount: 4,
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        0,
                        sidePadding,
                        20 + DashboardBottomNav.spaceOf(context),
                      ),
                      itemBuilder: (BuildContext _, int _) =>
                          const SkeletonListTile(thumbSize: 64, lines: 3),
                    )
                  : p.items.isEmpty
                  ? RefreshIndicator(
                      onRefresh: p.load,
                      color: AppColor.goldDeep,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints c) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: c.maxHeight,
                              ),
                              child: _Empty(
                                message:
                                    p.error?.message(l10n) ?? l10n.historyEmpty,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: p.load,
                      color: AppColor.goldDeep,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          sidePadding,
                          0,
                          sidePadding,
                          20 + DashboardBottomNav.spaceOf(context),
                        ),
                        itemCount: p.items.length,
                        separatorBuilder: (BuildContext _, int _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final BookingHistory item = p.items[index];
                          return HistoryCard(
                            item: item,
                            onReview: () => _openReview(context, p, item),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
        ),
      ),
    );
  }
}
