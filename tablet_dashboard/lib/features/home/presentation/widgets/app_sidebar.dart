import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/features/home/presentation/widgets/sidebar_account_tile.dart';
import 'package:tablet_dashboard/features/home/presentation/widgets/sidebar_brand.dart';
import 'package:tablet_dashboard/features/home/presentation/widgets/sidebar_nav_item.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';

// Navigasi kiri, bisa diperkecil jadi ikon saja
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  static const expandedWidth = 220.0;
  static const collapsedWidth = 76.0;

  static const _items = [
    (AppSection.dashboard, 'Dashboard', Icons.grid_view_rounded),
    (AppSection.order, 'Kasir', Icons.point_of_sale_outlined),
    (AppSection.settings, 'Konfigurasi', Icons.settings),
  ];

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Keluar dari dashboard?',
      message: 'Pesanan yang belum dibayar akan dihapus.',
      confirmLabel: 'Keluar',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    context.read<OrderController>().clearAll();
    context.read<NavigationController>().reset();
    context.read<SessionController>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final profile = context.select<SessionController, StaffProfile?>(
      (s) => s.profile,
    );
    final roleLabel = profile?.staffRole?.label ?? '';
    final expanded = nav.sidebarExpanded;
    final width = expanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      color: AppColor.ink,
      // Isi menu langsung pakai lebar akhir, frame animasi di-clip
      // supaya tidak overflow
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width,
          maxWidth: width,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              expanded ? 16 : 12,
              24,
              expanded ? 16 : 12,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SidebarBrand(
                  roleLabel: roleLabel,
                  expanded: expanded,
                  onToggle: nav.toggleSidebar,
                ),
                const SizedBox(height: 28),
                if (expanded)
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColor.sidebarDivider),
                      ),
                    ),
                    child: Text(
                      'Menu $roleLabel',
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.sidebarMuted,
                      ),
                    ),
                  )
                else
                  const Divider(color: AppColor.sidebarDivider),
                const SizedBox(height: 16),
                for (final (section, label, icon) in _items)
                  SidebarNavItem(
                    label: label,
                    icon: icon,
                    expanded: expanded,
                    selected: nav.section == section,
                    onTap: () => nav.go(section),
                  ),
                const Spacer(),
                if (profile != null)
                  SidebarAccountTile(
                    profile: profile,
                    expanded: expanded,
                    onSignOut: () => _signOut(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
