import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

enum DashboardTab { home, booking, history, profile }

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  static const double _radius = 28;

  /// Tinggi isi navbar pada ukuran font normal.
  /// 10 + 6 padding luar, 6 + 24 ikon + 5 + 16.6 label + 6 isi item = 73.6,
  /// dibulatkan ke 76 biar ada sisa napas.
  static const double _baseHeight = 76;

  /// Tinggi navbar tanpa area aman bawah, ikut skala font HP.
  static double _heightOf(BuildContext context) =>
      _baseHeight * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);

  /// Jarak isi terakhir halaman ke tepi atas navbar saat discroll mentok.
  /// Satu nilai untuk semua tab biar jaraknya seragam. Konten tidak lagi
  /// jalan di belakang navbar, jadi tinggi navbar tidak perlu ikut dihitung.
  static const double contentGap = 20;

  final DashboardTab current;
  final void Function(DashboardTab tab) onSelect;

  static String _iconOf(DashboardTab tab, {required bool active}) {
    switch (tab) {
      case DashboardTab.home:
        return active
            ? AppAssets.homeBottomActive
            : AppAssets.homeBottomInactive;
      case DashboardTab.booking:
        return active
            ? AppAssets.scissorsBottomActive
            : AppAssets.scissorsBottomInactive;
      case DashboardTab.history:
        return active
            ? AppAssets.historyBottomActive
            : AppAssets.historyBottomInactive;
      case DashboardTab.profile:
        return active
            ? AppAssets.profileBottomActive
            : AppAssets.profileBottomInactive;
    }
  }

  static String _labelOf(DashboardTab tab, AppLocalizations l10n) {
    switch (tab) {
      case DashboardTab.home:
        return l10n.navHome;
      case DashboardTab.booking:
        return l10n.navBooking;
      case DashboardTab.history:
        return l10n.navHistory;
      case DashboardTab.profile:
        return l10n.navProfile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Latar solid: konten tidak lewat di belakang navbar lagi.
    // Pakai Material (bukan DecoratedBox) biar efek tap InkWell tetap
    // kelihatan di atas latar yang tidak tembus pandang.
    return Material(
      color: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
        side: BorderSide(color: AppColor.ink),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _heightOf(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
            child: Row(
              children: <Widget>[
                for (final DashboardTab tab in DashboardTab.values)
                  Expanded(
                    child: _NavItem(
                      iconPath: _iconOf(tab, active: tab == current),
                      label: _labelOf(tab, l10n),
                      active: tab == current,
                      onTap: () => onSelect(tab),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColor.goldDeep.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColor.ink,
                fontWeight: active ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
