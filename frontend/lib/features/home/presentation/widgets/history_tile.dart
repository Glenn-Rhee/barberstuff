import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.history,
    required this.onTap,
    required this.onRebook,
  });

  static const double _radius = 12;

  final HaircutHistory history;
  final VoidCallback onTap;
  final VoidCallback onRebook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();

    final String subtitle =
        '${history.storeName} • '
        '${DateFormat('d MMM y', locale).format(history.date)}';

    return Material(
      color: AppColor.ink,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: const BorderSide(color: AppColor.goldDeep, width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      history.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSmall.copyWith(
                        fontSize: 15,
                        color: AppColor.surface,
                      ),
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
                    const SizedBox(height: 2),
                    _ByLine(
                      text: l10n.homeHistoryBy(history.capsterName),
                      name: history.capsterName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RebookButton(label: l10n.homeHistoryRebook, onTap: onRebook),
            ],
          ),
        ),
      ),
    );
  }
}

class _ByLine extends StatelessWidget {
  const _ByLine({required this.text, required this.name});

  final String text;
  final String name;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTextStyle.bodySmall.copyWith(
      color: AppColor.inkFaint,
    );
    final int at = text.indexOf(name);

    if (at < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }

    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          TextSpan(text: text.substring(0, at)),
          TextSpan(
            text: name,
            style: base.copyWith(
              color: AppColor.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(at + name.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RebookButton extends StatelessWidget {
  const _RebookButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.goldMid,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.ink.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
