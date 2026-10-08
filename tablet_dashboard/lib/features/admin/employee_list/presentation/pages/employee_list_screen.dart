import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/employee_create/presentation/pages/employee_create_screen.dart';
import 'package:tablet_dashboard/features/admin/employee_list/domain/entities/employee.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/provider/employee_list_controller.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/widgets/employee_dialogs.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/widgets/employee_stat_card.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/select_box.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';
import 'package:tablet_dashboard/shared/widgets/table/branch_table.dart';

// Manajemen Karyawan: ringkasan, filter, dan daftar karyawan semua cabang
class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  static const _flex = [5, 3, 4, 5, 3, 3];

  // '' = semua cabang, karena nilai null dianggap batal oleh menu
  static const _allBranches = '';

  Future<void> _create(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const EmployeeCreateScreen()));

  Future<void> _delete(BuildContext context, Employee employee) async {
    final list = context.read<EmployeeListController>();
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus karyawan?',
      message: employee.isCapster
          ? '${employee.name} tidak tampil lagi di kasir dan aplikasi '
                'pelanggan.'
          : '${employee.name} (${employee.email}) tidak bisa login ke '
                'tablet lagi.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    final error = await list.delete(employee);
    if (!context.mounted) return;
    AppToast.show(
      context,
      error ?? 'Karyawan ${employee.name} dihapus',
      error: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<EmployeeListController>();
    final loaded = !list.loading && list.error == null;

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
                  onPressed: () => _create(context),
                  style: FilledButton.styleFrom(
                    elevation: 2,
                    shadowColor: AppColor.gold.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  icon: const AppIcon(AppAsset.plusIcon, size: 14),
                  label: const Text('Tambah Karyawan'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: EmployeeStatCard(
                    icon: AppAsset.employeesIcon,
                    background: AppColor.warningSoft,
                    label: 'Total Karyawan',
                    value: loaded ? list.all.length : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EmployeeStatCard(
                    icon: AppAsset.employeeActiveIcon,
                    background: AppColor.successSoft,
                    label: 'Aktif',
                    value: loaded ? list.activeCount : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EmployeeStatCard(
                    icon: AppAsset.employeeInactiveIcon,
                    background: AppColor.dangerSoft,
                    label: 'Tidak Aktif',
                    value: loaded ? list.inactiveCount : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EmployeeStatCard(
                    icon: AppAsset.buildingIcon,
                    background: AppColor.infoSoft,
                    label: 'Jumlah Cabang',
                    value: loaded ? list.branches.length : null,
                  ),
                ),
              ],
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
                    _filters(list),
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
                    Expanded(child: _body(context, list)),
                    if (loaded && list.totalPages > 1) ...[
                      const SizedBox(height: 12),
                      PaginationBar(
                        page: list.page - 1,
                        pageCount: list.totalPages,
                        onChanged: (page) => list.setPage(page + 1),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters(EmployeeListController list) {
    final branchNames = {for (final b in list.branches) b.id: b.name};

    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            hint: 'Cari nama atau email...',
            initialValue: list.query,
            onChanged: list.setQuery,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 190,
          child: SelectBox<String>(
            value: list.branchId ?? _allBranches,
            options: [_allBranches, ...branchNames.keys],
            labelOf: (id) => branchNames[id] ?? 'Semua Cabang',
            onChanged: (id) => list.setBranch(id == _allBranches ? null : id),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 170,
          child: SelectBox<EmployeeRoleFilter>(
            value: list.roleFilter,
            options: EmployeeRoleFilter.values,
            labelOf: (f) => f.label,
            onChanged: list.setRole,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 160,
          child: SelectBox<EmployeeStatusFilter>(
            value: list.status,
            options: EmployeeStatusFilter.values,
            labelOf: (f) => f.label,
            onChanged: list.setStatus,
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, EmployeeListController list) {
    if (list.loading) {
      return const SkeletonRows(flex: _flex, count: 5, avatar: true);
    }
    if (list.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat karyawan',
        message: list.error!,
        onRetry: list.refresh,
      );
    }
    final employees = list.visible;
    if (employees.isEmpty) {
      return EmptyState(
        icon: Icons.badge_outlined,
        title: list.all.isEmpty
            ? 'Belum ada karyawan'
            : 'Karyawan tidak ditemukan',
        message: list.all.isEmpty
            ? 'Tambah karyawan lewat tombol Tambah Karyawan.'
            : 'Coba kata kunci atau filter lain.',
      );
    }
    return RefreshIndicator(
      onRefresh: list.refresh,
      child: ListView(
        children: [for (final employee in employees) _row(context, employee)],
      ),
    );
  }

  Widget _row(BuildContext context, Employee employee) {
    final muted = AppTextStyle.body.copyWith(color: AppColor.inkSoft);

    return BranchTableRow(
      flex: _flex,
      children: [
        Row(
          children: [
            PersonAvatar(
              name: employee.name,
              photo: employee.photoUrl,
              size: 36,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                employee.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyBold,
              ),
            ),
          ],
        ),
        Text(employee.role.label, style: muted),
        Text(
          employee.branch.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: muted,
        ),
        Text(
          employee.email ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: muted,
        ),
        ActiveBadge(active: employee.active),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RowIconButton(
              asset: AppAsset.viewIcon,
              tooltip: 'Lihat',
              onTap: () => showEmployeeDetail(context, employee),
            ),
            const SizedBox(width: 6),
            RowIconButton(
              asset: AppAsset.editEmployeeIcon,
              tooltip: 'Ubah',
              onTap: () => showEmployeeEdit(context, employee),
            ),
            const SizedBox(width: 6),
            RowIconButton(
              asset: AppAsset.deleteEmployeeIcon,
              tooltip: 'Hapus',
              background: AppColor.dangerSoft,
              onTap: () => _delete(context, employee),
            ),
          ],
        ),
      ],
    );
  }
}
