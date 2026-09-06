import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.history, required this.onTap});

  final HaircutHistory history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String subtitle =
        '${DateFormat('EEEE, d MMMM y', locale).format(history.date)}'
        ' • ${history.storeName}';

    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.orangeDashboard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.historyRoundedDashboard,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    color: AppColor.ink,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      history.capsterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(_price(history.price), style: AppTextStyle.titleSmall),
            ],
          ),
        ),
      ),
    );
  }

  static String _price(int value) {
    if (value >= 1000 && value % 1000 == 0) return 'Rp${value ~/ 1000}k';
    return 'Rp${NumberFormat.decimalPattern('id').format(value)}';
  }
}
