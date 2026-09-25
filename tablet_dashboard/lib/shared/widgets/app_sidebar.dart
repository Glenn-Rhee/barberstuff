import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation_controller.dart';
import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';
import '../../features/auth/presentation/provider/session_controller.dart';
import '../../features/cashier/presentation/provider/order_controller.dart';
import '../models/person.dart';
import 'common.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  static const expandedWidth = 220.0;
  static const collapsedWidth = 76.0;

  static const _items = [
    (AppSection.dashboard, 'Dashboard', Icons.grid_view_rounded),
    (AppSection.kasir, 'Kasir', Icons.point_of_sale_outlined),
    (AppSection.pelanggan, 'Pelanggan', Icons.people_alt_outlined),
    (AppSection.pembukuan, 'Pembukuan', Icons.menu_book_outlined),
    (AppSection.konfigurasi, 'Konfigurasi', Icons.settings),
  ];

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Keluar dari kasir?',
      message: 'Pesanan yang belum dibayar akan dihapus.',
      confirmLabel: 'Keluar',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    context.read<OrderController>().clearAll();
    context.read<SessionController>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final cashier = context.select<SessionController, StaffProfile?>((s) => s.profile);
    final expanded = nav.sidebarExpanded;

    final width = expanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      color: AppColor.sidebar,
      // The menu keeps its final width while the rail animates, so the frames
      // in between clip instead of overflowing.
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width,
          maxWidth: width,
          child: Padding(
            padding: EdgeInsets.fromLTRB(expanded ? 16 : 12, 24, expanded ? 16 : 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Brand(expanded: expanded, onToggle: nav.toggleSidebar),
                const SizedBox(height: 28),
                if (expanded)
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColor.sidebarDivider)),
                    ),
                    child: Text('Dashboard Kasir', style: AppTextStyle.body.copyWith(color: AppColor.sidebarMuted)),
                  )
                else
                  const Divider(color: AppColor.sidebarDivider),
                const SizedBox(height: 16),
                for (final (section, label, icon) in _items)
                  _NavItem(
                    label: label,
                    icon: icon,
                    expanded: expanded,
                    selected: nav.section == section,
                    onTap: () => nav.go(section),
                  ),
                const Spacer(),
                if (cashier != null)
                  _CashierTile(cashier: cashier, expanded: expanded, onSignOut: () => _signOut(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Image.asset('assets/images/logo_glyph.png', color: AppColor.sidebar),
    );
    final toggle = _IconAction(
      icon: expanded ? Icons.chevron_left : Icons.chevron_right,
      tooltip: expanded ? 'Perkecil menu' : 'Perbesar menu',
      onTap: onToggle,
    );

    if (!expanded) {
      return Column(children: [logo, const SizedBox(height: 12), toggle]);
    }

    return Row(
      children: [
        logo,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BARBERSTUFF',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyStrong.copyWith(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'KASIR',
                style: AppTextStyle.overline.copyWith(color: AppColor.sidebarMuted, fontSize: 9, letterSpacing: 1),
              ),
            ],
          ),
        ),
        toggle,
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColor.ink : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: expanded ? '' : label,
        child: Material(
          color: selected ? AppColor.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
              child: Row(
                mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: foreground),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.body.copyWith(
                          color: foreground,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashierTile extends StatelessWidget {
  const _CashierTile({required this.cashier, required this.expanded, required this.onSignOut});

  final StaffProfile cashier;
  final bool expanded;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final signOut = _IconAction(icon: Icons.logout, tooltip: 'Keluar', onTap: onSignOut);

    if (!expanded) {
      return Column(
        children: [
          PersonAvatar(name: cashier.name, size: 36),
          const SizedBox(height: 10),
          signOut,
        ],
      );
    }

    return Row(
      children: [
        PersonAvatar(name: cashier.name, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cashier.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyStrong.copyWith(color: Colors.white),
              ),
              Text(cashier.roleLabel, style: AppTextStyle.caption.copyWith(color: AppColor.sidebarMuted)),
            ],
          ),
        ),
        signOut,
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColor.sidebarMuted),
        ),
      ),
    );
  }
}
