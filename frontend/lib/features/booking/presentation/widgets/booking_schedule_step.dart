import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingScheduleStep extends StatelessWidget {
  const BookingScheduleStep({super.key});

  static const double _dayWidth = 58;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.bookingDateLabel, style: AppTextStyle.titleMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 74 + (scale - 1) * 26,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: p.days.length,
            separatorBuilder: (BuildContext _, int _) =>
                const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final DateTime day = p.days[index];
              return SizedBox(
                width: _dayWidth,
                child: _DayChip(
                  weekday: DateFormat('EEE', locale).format(day),
                  dayNumber: DateFormat('d', locale).format(day),
                  selected: DateUtils.isSameDay(p.date, day),
                  onTap: () => p.selectDate(day),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.bookingTimeLabel, style: AppTextStyle.titleMedium),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 520 ? 6 : 4;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 46 + (scale - 1) * 16,
                ),
                itemCount: p.slots.length,
                itemBuilder: (BuildContext context, int index) {
                  final TimeOfDay slot = p.slots[index];
                  final bool selected =
                      p.time?.hour == slot.hour &&
                      p.time?.minute == slot.minute;

                  return _SlotChip(
                    label: _format(slot),
                    selected: selected,
                    onTap: () => p.selectTime(slot),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  static String _format(TimeOfDay t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.weekday,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final String dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColor.surface : AppColor.ink;

    return Material(
      color: selected ? AppColor.orangeLight : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColor.orangeLight : AppColor.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                weekday,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  color: selected ? AppColor.surface : AppColor.inkSoft,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dayNumber,
                maxLines: 1,
                style: AppTextStyle.titleMedium.copyWith(color: foreground),
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
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColor.orangeLight : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColor.orangeLight : AppColor.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyle.labelMedium.copyWith(
                color: selected ? AppColor.surface : AppColor.ink,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
