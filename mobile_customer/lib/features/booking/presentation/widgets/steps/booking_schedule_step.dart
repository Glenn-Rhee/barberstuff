import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_step_shell.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingScheduleStep extends StatelessWidget {
  const BookingScheduleStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final String locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            l10n.bookingDateLabel,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
          ),
        ),
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: p.days.length,
            separatorBuilder: (BuildContext _, int _) =>
                const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final DateTime day = p.days[index];
              return _DayChip(
                day: day,
                locale: locale,
                selected: DateUtils.isSameDay(day, p.selectedDay),
                onTap: () => p.selectDay(day),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            l10n.bookingTimeLabel,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
          ),
        ),
        Expanded(
          child: BookingStepState(
            loading: p.loadingSlots,
            error: p.slotsError,
            isEmpty: p.slots.isEmpty,
            emptyMessage: l10n.bookingSlotEmpty,
            onRetry: p.loadSlots,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemCount: p.slots.length,
              itemBuilder: (BuildContext context, int index) {
                final BookingSlot s = p.slots[index];
                return _SlotChip(
                  slot: s,
                  selected: p.slot?.time == s.time,
                  onTap: () => p.selectSlot(s),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                AppAssets.questionSlotBook,
                width: 13,
                height: 13,
                fit: BoxFit.contain,
                color: p.isSlotTooSoon ? AppColor.danger : AppColor.inkFaint,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.isSlotTooSoon
                      ? l10n.bookingSlotTooSoon
                      : l10n.bookingSlotFullNote,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 11,
                    color: p.isSlotTooSoon
                        ? AppColor.danger
                        : AppColor.inkFaint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColor.goldDeep : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? AppColor.goldDeep : AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('EEE', locale).format(day),
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  color: selected ? AppColor.surface : AppColor.inkFaint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('d').format(day),
                style: AppTextStyle.titleSmall.copyWith(
                  fontSize: 15,
                  color: selected ? AppColor.surface : AppColor.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final BookingSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = slot.available;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: selected ? AppColor.goldDeep : AppColor.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? AppColor.goldDeep : AppColor.border,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              slot.time,
              maxLines: 1,
              style: AppTextStyle.labelMedium.copyWith(
                fontSize: 13,
                color: selected ? AppColor.surface : AppColor.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
