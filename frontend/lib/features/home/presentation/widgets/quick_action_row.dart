import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

enum QuickAction { booking, package, promo, history }

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key, required this.onSelect});

  final void Function(QuickAction action) onSelect;

  static String _iconOf(QuickAction action) {
    switch (action) {
      case QuickAction.booking:
        return AppAssets.scissorsDashboard;
      case QuickAction.package:
        return AppAssets.tagDashboard;
      case QuickAction.promo:
        return AppAssets.giftDashboard;
      case QuickAction.history:
        return AppAssets.barcodeDashboard;
    }
  }

  static String _labelOf(QuickAction action, AppLocalizations l10n) {
    switch (action) {
      case QuickAction.booking:
        return l10n.homeActionBooking;
      case QuickAction.package:
        return l10n.homeActionPackage;
      case QuickAction.promo:
        return l10n.homeActionPromo;
      case QuickAction.history:
        return l10n.homeActionHistory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final QuickAction action in QuickAction.values)
          Expanded(
            child: _ActionItem(
              iconPath: _iconOf(action),
              label: _labelOf(action, l10n),
              onTap: () => onSelect(action),
            ),
          ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  static const double _maxTile = 68;
  static const double _radius = 18;

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double size = constraints.maxWidth * 0.82 < _maxTile
                ? constraints.maxWidth * 0.82
                : _maxTile;

            return Center(
              child: Material(
                color: AppColor.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  side: const BorderSide(color: AppColor.goldDeep, width: 1.5),
                ),
                child: InkWell(
                  onTap: onTap,
                  splashColor: AppColor.goldDeep.withValues(alpha: 0.16),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Center(
                      child: Image.asset(
                        iconPath,
                        width: size * 0.42,
                        height: size * 0.42,
                        fit: BoxFit.contain,
                        color: AppColor.ink,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.labelMedium,
        ),
      ],
    );
  }
}
