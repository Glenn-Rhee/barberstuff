import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/employee_list/domain/entities/employee.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/provider/employee_list_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/password_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/select_box.dart';
import 'package:tablet_dashboard/shared/widgets/table/branch_table.dart';

// Detail satu karyawan, cuma data yang ada di backend
Future<void> showEmployeeDetail(BuildContext context, Employee employee) =>
    showDialog<void>(
      context: context,
      builder: (_) => _EmployeeDetailDialog(employee: employee),
    );

// Ubah capster (nama, status, cabang) atau akun (nama + password baru)
Future<void> showEmployeeEdit(BuildContext context, Employee employee) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<EmployeeListController>(),
      child: employee.isCapster
          ? _CapsterEditDialog(employee: employee)
          : _AccountEditDialog(employee: employee),
    ),
  );
  if (saved == true && context.mounted) {
    AppToast.show(context, 'Karyawan ${employee.name} disimpan');
  }
}

class _EmployeeDetailDialog extends StatelessWidget {
  const _EmployeeDetailDialog({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PersonAvatar(
                    name: employee.name,
                    photo: employee.photoUrl,
                    size: 56,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: AppTextStyle.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          label: employee.role.label,
                          color: AppColor.ink,
                          background: AppColor.surfaceMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoRow(label: 'Cabang', value: Text(employee.branch.name)),
              if (employee.email != null)
                _InfoRow(label: 'Email', value: Text(employee.email!)),
              if (employee.isCapster)
                _InfoRow(
                  label: 'Rating',
                  value: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon(
                        AppAsset.fullStarIcon,
                        size: 14,
                        tint: false,
                      ),
                      const SizedBox(width: 4),
                      Text(employee.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              _InfoRow(
                label: 'Status',
                value: ActiveBadge(active: employee.active),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    side: const BorderSide(color: AppColor.borderStrong),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTextStyle.bodyMedium,
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsterEditDialog extends StatefulWidget {
  const _CapsterEditDialog({required this.employee});

  final Employee employee;

  @override
  State<_CapsterEditDialog> createState() => _CapsterEditDialogState();
}

class _CapsterEditDialogState extends State<_CapsterEditDialog> {
  late final _name = TextEditingController(text: widget.employee.name);
  late bool _active = widget.employee.active;
  late Branch _branch = widget.employee.branch;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    final list = context.watch<EmployeeListController>();
    final name = _name.text.trim();
    final changed =
        name != employee.name ||
        _active != employee.active ||
        _branch.id != employee.branch.id;

    return AppFormDialog(
      title: 'Ubah Karyawan',
      subtitle: 'Capster · ${employee.branch.name}',
      canSubmit: changed && name.length >= 3,
      // Field yang tidak berubah tidak dikirim, backend menolak update kosong
      onSubmit: () => list.updateCapster(
        employee,
        name: name == employee.name ? null : name,
        active: _active == employee.active ? null : _active,
        branchId: _branch.id == employee.branch.id ? null : _branch.id,
      ),
      children: [
        const FieldLabel('Nama', required: true),
        TextField(
          controller: _name,
          style: AppTextStyle.body,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Status', required: true),
        SelectBox<bool>(
          value: _active,
          options: const [true, false],
          labelOf: (active) => active ? 'Aktif' : 'Tidak Aktif',
          onChanged: (value) => setState(() => _active = value),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Cabang', required: true),
        SelectBox<Branch>(
          value: list.branches.where((b) => b.id == _branch.id).firstOrNull,
          options: list.branches,
          labelOf: (branch) => branch.name,
          onChanged: (branch) => setState(() => _branch = branch),
        ),
      ],
    );
  }
}

class _AccountEditDialog extends StatefulWidget {
  const _AccountEditDialog({required this.employee});

  final Employee employee;

  @override
  State<_AccountEditDialog> createState() => _AccountEditDialogState();
}

class _AccountEditDialogState extends State<_AccountEditDialog> {
  late final _name = TextEditingController(text: widget.employee.name);
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;

    return AppFormDialog(
      title: 'Ubah Akun',
      subtitle: '${employee.role.label} · ${employee.email}',
      canSubmit:
          _name.text.trim().length >= 3 && _password.text.trim().length >= 5,
      onSubmit: () => context.read<EmployeeListController>().updateAccount(
        employee,
        name: _name.text.trim(),
        password: _password.text.trim(),
      ),
      children: [
        const FieldLabel('Nama', required: true),
        TextField(
          controller: _name,
          style: AppTextStyle.body,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Password Baru', required: true),
        PasswordField(
          controller: _password,
          hint: 'Minimal 5 karakter',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Wajib isi password baru, beri tahu staff.',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        ),
      ],
    );
  }
}
