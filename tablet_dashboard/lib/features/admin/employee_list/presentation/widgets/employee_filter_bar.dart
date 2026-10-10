import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/admin/branch_list/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/select_box.dart';

enum EmployeeRoleFilter {
  all('Semua Jabatan'),
  capster('Capster'),
  cashier('Kasir'),
  mitra('Mitra');

  const EmployeeRoleFilter(this.label);

  final String label;
}

enum EmployeeStatusFilter {
  all('Semua Status'),
  active('Aktif'),
  inactive('Tidak Aktif');

  const EmployeeStatusFilter(this.label);

  final String label;
}

// Cari + filter cabang / jabatan / status, semua tinggi 44.
// Belum terhubung ke daftar karyawan
class EmployeeFilterBar extends StatefulWidget {
  const EmployeeFilterBar({super.key});

  @override
  State<EmployeeFilterBar> createState() => _EmployeeFilterBarState();
}

class _EmployeeFilterBarState extends State<EmployeeFilterBar> {
  static const _gap = SizedBox(width: 12);

  // '' = semua cabang
  String _branchId = '';
  EmployeeRoleFilter _role = EmployeeRoleFilter.all;
  EmployeeStatusFilter _status = EmployeeStatusFilter.all;

  @override
  void initState() {
    super.initState();
    // Daftar cabang dari GET /store, dimuat kalau halaman cabang belum dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final branches = context.read<BranchListController>();
      if (branches.all.isEmpty) branches.refresh(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final branchNames = {
      '': 'Semua Cabang',
      for (final branch in context.watch<BranchListController>().all)
        branch.id: branch.name,
    };

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: AppSearchField(
            hint: 'Cari nama atau nomor telepon...',
            onChanged: (_) {},
          ),
        ),
        _gap,
        Expanded(
          flex: 3,
          child: SelectBox<String>(
            value: _branchId,
            options: branchNames.keys.toList(),
            labelOf: (id) => branchNames[id] ?? 'Semua Cabang',
            onChanged: (id) => setState(() => _branchId = id),
          ),
        ),
        _gap,
        Expanded(
          flex: 3,
          child: SelectBox<EmployeeRoleFilter>(
            value: _role,
            options: EmployeeRoleFilter.values,
            labelOf: (role) => role.label,
            onChanged: (role) => setState(() => _role = role),
          ),
        ),
        _gap,
        Expanded(
          flex: 3,
          child: SelectBox<EmployeeStatusFilter>(
            value: _status,
            options: EmployeeStatusFilter.values,
            labelOf: (status) => status.label,
            onChanged: (status) => setState(() => _status = status),
          ),
        ),
      ],
    );
  }
}
