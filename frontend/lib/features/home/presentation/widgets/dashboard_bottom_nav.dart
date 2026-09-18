import 'dart:ui' show ImageFilter;

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
  static double heightOf(BuildContext context) =>
      _baseHeight * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);

  /// Ruang yang harus disisakan halaman di bagian bawah biar
  /// isi terakhirnya tidak ketutup navbar.
  static double spaceOf(BuildContext context) =>
      heightOf(context) + MediaQuery.paddingOf(context).bottom;

  final DashboardTab current;
  final void Function(DashboardTab tab) onSelect;

  static String _iconOf(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.home:
        return AppAssets.homeBottom;
      case DashboardTab.booking:
        return AppAssets.scissorsBottom;
      case DashboardTab.history:
        return AppAssets.historyBottom;
      case DashboardTab.profile:
        return AppAssets.userBottom;
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

    // Konten halaman jalan di belakang navbar, jadi latarnya dibuat buram
    // tembus pandang biar ikon tetap kebaca tanpa blok putih solid.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.surface.withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(color: AppColor.backdrop.withValues(alpha: 0.06)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: heightOf(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                child: Row(
                  children: <Widget>[
                    for (final DashboardTab tab in DashboardTab.values)
                      Expanded(
                        child: _NavItem(
                          iconPath: _iconOf(tab),
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
    final Color tint = active ? AppColor.goldDeep : AppColor.inkSoft;

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
              color: tint,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTextStyle.labelSmall.copyWith(
                color: tint,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
