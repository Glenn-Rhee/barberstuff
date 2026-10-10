import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/employee_create/presentation/pages/employee_create_screen.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/widgets/employee_filter_bar.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/widgets/grid_tabel_stat.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/table/branch_table.dart';

// Manajemen Karyawan: kerangka tabel, belum terhubung API
class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  static const _flex = [5, 3, 4, 5, 3, 3];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Manajemen Karyawan',
              subtitle:
                  'Kelola biodata dan hak akses seluruh karyawan Barberstuff.',
              actions: [
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmployeeCreateScreen(),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    elevation: 2,
                    shadowColor: AppColor.gold.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  icon: const AppIcon(AppAsset.plusIcon, size: 14),
                  label: const Text('Tambah Karyawan'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            GridTabelStat(),
            const SizedBox(height: 24),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Daftar Karyawan',
                      style: AppTextStyle.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const EmployeeFilterBar(),
                    const SizedBox(height: 16),
                    const BranchTableHeader(
                      labels: [
                        'KARYAWAN',
                        'JABATAN',
                        'CABANG',
                        'NOMOR TELEPON',
                        'STATUS',
                        'AKSI',
                      ],
                      flex: _flex,
                      color: AppColor.surfaceSubtle,
                    ),
                    const Expanded(
                      child: EmptyState(
                        icon: Icons.badge_outlined,
                        title: 'Belum ada data karyawan',
                        message: 'Data Kosong',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
