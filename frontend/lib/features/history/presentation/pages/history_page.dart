import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/history_provider.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/history_card.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/review_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryProvider>(
      create: (BuildContext ctx) =>
          HistoryProvider(ctx.read<HistoryRepository>()),
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
    );
    if (draft == null || !context.mounted) return;

    final bool ok = await p.submitReview(item.id, draft);
    if (!ok || !context.mounted) return;

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
              padding: const EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 14),
              child: Text(
                l10n.historyTitle,
                style: AppTextStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 12),
              child: _SearchBar(
                controller: p.searchController,
                hint: l10n.bookingSearchHint,
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                children: <Widget>[
                  for (final HistoryTab tab in HistoryTab.values) ...<Widget>[
                    _TabChip(
                      label: _tabLabel(tab, l10n),
                      active: p.tab == tab,
                      onTap: () => p.setTab(tab),
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: p.isLoading
                  ? const Center(child: BoxLoader())
                  : p.items.isEmpty
                  ? _Empty(message: l10n.historyEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        sidePadding,
                        0,
                        sidePadding,
                        20,
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
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
            cursorColor: AppColor.goldDeep,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: AppTextStyle.bodySmall.copyWith(
                fontSize: 13,
                color: AppColor.inkFaint,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: _border(AppColor.border),
              enabledBorder: _border(AppColor.border),
              focusedBorder: _border(AppColor.goldDeep),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColor.goldDeep,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            AppAssets.searchBookingIcon,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            color: AppColor.surface,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColor.goldDeep : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColor.goldDeep),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyle.labelMedium.copyWith(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColor.surface : AppColor.goldDeep,
              ),
            ),
          ),
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
