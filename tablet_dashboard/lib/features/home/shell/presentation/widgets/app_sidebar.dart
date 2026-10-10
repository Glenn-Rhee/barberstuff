import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/login/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/widgets/sidebar_account_tile.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/widgets/sidebar_brand.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/widgets/sidebar_nav_item.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';

// Navigasi kiri, bisa diperkecil jadi ikon saja
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  // Harus cukup untuk label terpanjang, kalau kurang label otomatis mengecil
  static const expandedWidth = 264.0;
  static const collapsedWidth = 76.0;

  static const _items = [
    (AppSection.dashboard, 'Dashboard', AppAsset.gridIcon),
    (AppSection.order, 'Kasir', AppAsset.stackIcon),
    (AppSection.customers, 'Pelanggan', AppAsset.personIcon),
    (AppSection.bookkeeping, 'Pembukuan', AppAsset.cashIcon),
    (AppSection.settings, 'Konfigurasi', AppAsset.settingIcon),
  ];

  // Menu admin pakai ikon stack, jadi grid saat sedang dibuka
  static const _adminItems = [
    (AppSection.admindash, 'Dashboard', AppAsset.stackIcon),
    (AppSection.branches, 'Mengelola Cabang', AppAsset.stackIcon),
    (AppSection.employees, 'Manajemen Karyawan', AppAsset.stackIcon),
    (AppSection.financialStatements, 'Laporan Keuangan', AppAsset.stackIcon),
    (AppSection.manageApps, 'Manajemen Aplikasi', AppAsset.stackIcon),
  ];

  // Ukuran font label 'Manajemen Karyawan' saja, menu lain tetap 14
  static const employeesLabelFontSize = 15.0;

  static List<(AppSection, String, String)> _itemsFor(StaffRole? role) =>
      role == StaffRole.admin ? _adminItems : _items;

  Widget _navItem(
    NavigationController nav, {
    required StaffRole? role,
    required AppSection section,
    required String label,
    required String icon,
    required bool expanded,
  }) {
    final selected = nav.sectionFor(role) == section;
    return SidebarNavItem(
      label: label,
      icon: role == StaffRole.admin && selected ? AppAsset.gridIcon : icon,
      expanded: expanded,
      selected: selected,
      onTap: () => nav.go(section),
      labelFontSize: section == AppSection.employees
          ? employeesLabelFontSize
          : null,
    );
  }

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
    context.read<StoreController>().clear();
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
      // Isi pakai lebar akhir, frame animasi di-clip supaya tidak overflow
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
                      'Dashboard $roleLabel',
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.sidebarMuted,
                      ),
                    ),
                  )
                else
                  const Divider(color: AppColor.sidebarDivider),
                const SizedBox(height: 16),
                for (final (section, label, icon) in _itemsFor(
                  profile?.staffRole,
                ))
                  _navItem(
                    nav,
                    role: profile?.staffRole,
                    section: section,
                    label: label,
                    icon: icon,
                    expanded: expanded,
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
