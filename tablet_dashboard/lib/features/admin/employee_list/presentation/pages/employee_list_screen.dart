import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
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
            const PageHeader(
              title: 'Manajemen Karyawan',
              subtitle:
                  'Kelola biodata dan hak akses seluruh karyawan Barberstuff.',
            ),
            const SizedBox(height: 20),
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
                    const BranchTableHeader(
                      labels: [
                        'KARYAWAN',
                        'JABATAN',
                        'CABANG',
                        'EMAIL',
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
                        message: 'Data karyawan belum terhubung ke API.',
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
