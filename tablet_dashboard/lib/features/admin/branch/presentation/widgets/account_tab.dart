import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/account_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_table.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/password_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tab Role Akun: akun kasir / mitra yang bisa login ke cabang ini,
// form tambah akun di kanan
class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _AccountListCard()),
        SizedBox(width: 20),
        SizedBox(width: 340, child: _AccountFormCard()),
      ],
    );
  }
}

class _AccountListCard extends StatelessWidget {
  const _AccountListCard();

  static const _flex = [4, 5, 2, 3];

  Future<void> _edit(BuildContext context, StaffAccount account) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AccountListController>(),
        child: _AccountEditDialog(account: account),
      ),
    );
    if (saved == true && context.mounted) {
      AppToast.show(context, 'Akun ${account.email} disimpan');
    }
  }

  Future<void> _delete(BuildContext context, StaffAccount account) async {
    final list = context.read<AccountListController>();
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus akun?',
      message:
          '${account.name} (${account.email}) tidak bisa login ke tablet lagi.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    final error = await list.delete(account);
    if (!context.mounted) return;
    AppToast.show(
      context,
      error ?? 'Akun ${account.email} dihapus',
      error: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AccountListController>();
    final accounts = list.visible;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Akun Cabang', style: AppTextStyle.h3),
          Text(
            'Kelola akun yang dapat login dan mengakses cabang ini.',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hint: 'Cari nama atau email...',
                  initialValue: list.query,
                  onChanged: list.setQuery,
                ),
              ),
              const SizedBox(width: 12),
              DropdownChip<AccountRoleFilter>(
                value: list.filter,
                options: AccountRoleFilter.values,
                labelOf: (f) => f.label,
                onChanged: list.setFilter,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const BranchTableHeader(
            labels: ['NAMA', 'EMAIL', 'ROLE', 'AKSI'],
            flex: _flex,
          ),
          if (list.loading)
            const SkeletonRows(flex: _flex, count: 2, rowHeight: 60)
          else if (list.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ErrorRetryView(
                title: 'Gagal memuat akun',
                message: list.error!,
                onRetry: list.refresh,
              ),
            )
          else if (accounts.isEmpty)
            EmptyState(
              icon: Icons.manage_accounts_outlined,
              title: list.all.isEmpty
                  ? 'Belum ada akun'
                  : 'Akun tidak ditemukan',
              message: list.all.isEmpty
                  ? 'Buat akun kasir atau mitra lewat form di kanan.'
                  : 'Coba kata kunci atau role lain.',
            )
          else
            for (final account in accounts)
              BranchTableRow(
                flex: _flex,
                children: [
                  Row(
                    children: [
                      PersonAvatar(name: account.name, size: 32),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bodyBold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    account.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
                  ),
                  StatusBadge(
                    label: account.role?.label ?? '-',
                    color: AppColor.ink,
                    background: AppColor.surfaceMuted,
                  ),
                  RowActions(
                    onEdit: () => _edit(context, account),
                    onDelete: () => _delete(context, account),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          Text(
            'Maks. ${AccountListController.maxAccounts} akun per cabang: '
            '1 Kasir dan 1 Mitra.',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _AccountFormCard extends StatefulWidget {
  const _AccountFormCard();

  @override
  State<_AccountFormCard> createState() => _AccountFormCardState();
}

class _AccountFormCardState extends State<_AccountFormCard> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _name = TextEditingController();
  final _email = TextEditingController();
  StaffRole? _role;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _name.clear();
    _email.clear();
    _role = null;
    _error = null;
  });

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final role = _role;
    final error = name.length < 3
        ? 'Nama minimal 3 huruf'
        : !_emailPattern.hasMatch(email)
        ? 'Format email tidak valid'
        : role == null
        ? 'Pilih role akun'
        : null;
    if (error != null || role == null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final failed = await context.read<AccountListController>().create(
      name: name,
      email: email,
      role: role,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failed;
    });
    if (failed != null) return;
    _reset();
    AppToast.show(context, 'Akun ${role.label} $email dibuat');
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AccountListController>();
    final branchName = context.select<BranchDetailController, String>(
      (c) => c.branch.name,
    );
    final locked = list.full || list.loading || list.error != null;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tambah Akun Cabang', style: AppTextStyle.title),
          const SizedBox(height: 16),
          if (list.full) ...[
            const MessageBox(
              message:
                  'Cabang ini sudah punya 1 Kasir dan 1 Mitra. Hapus salah '
                  'satu akun untuk menambah yang baru.',
            ),
            const SizedBox(height: 16),
          ],
          const FieldLabel('Nama', required: true),
          TextField(
            controller: _name,
            enabled: !locked && !_busy,
            style: AppTextStyle.body,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama lengkap',
            ),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Email', required: true),
          TextField(
            controller: _email,
            enabled: !locked && !_busy,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyle.body,
            decoration: const InputDecoration(hintText: 'nama@barberstuff.id'),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Role', required: true),
          _RoleSelect(
            value: _role,
            enabled: !locked && !_busy,
            taken: list.taken,
            onChanged: (role) => setState(() => _role = role),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColor.inkSoft),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Akun akan terhubung otomatis ke $branchName. Password awal '
                  'memakai password default staff dari server, minta staff '
                  'menggantinya setelah login.',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            MessageBox(message: _error!),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    side: const BorderSide(color: AppColor.borderStrong),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: locked || _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.gold,
                          ),
                        )
                      : const Text('Simpan Akun'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Pilih Kasir / Mitra, role yang sudah dipakai cabang tidak bisa dipilih
class _RoleSelect extends StatelessWidget {
  const _RoleSelect({
    required this.value,
    required this.enabled,
    required this.taken,
    required this.onChanged,
  });

  final StaffRole? value;
  final bool enabled;
  final bool Function(StaffRole) taken;
  final ValueChanged<StaffRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StaffRole>(
      enabled: enabled,
      tooltip: '',
      // Di atas toast, bukan di dalam navigator cabang
      useRootNavigator: true,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final role in AccountListController.roles)
          PopupMenuItem(
            value: role,
            enabled: !taken(role),
            child: Text(
              taken(role) ? '${role.label} (sudah ada)' : role.label,
              style: AppTextStyle.body,
            ),
          ),
      ],
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColor.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value != null ? AppColor.gold : AppColor.borderStrong,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value?.label ?? 'Pilih role',
                style: AppTextStyle.body.copyWith(
                  color: value == null ? AppColor.inkFaint : null,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColor.inkSoft),
          ],
        ),
      ),
    );
  }
}

// Ubah nama akun. Backend selalu minta password baru sekaligus
class _AccountEditDialog extends StatefulWidget {
  const _AccountEditDialog({required this.account});

  final StaffAccount account;

  @override
  State<_AccountEditDialog> createState() => _AccountEditDialogState();
}

class _AccountEditDialogState extends State<_AccountEditDialog> {
  late final _name = TextEditingController(text: widget.account.name);
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Ubah Akun',
      subtitle:
          '${widget.account.role?.label ?? 'Akun'} · ${widget.account.email}',
      canSubmit:
          _name.text.trim().length >= 3 && _password.text.trim().length >= 5,
      onSubmit: () => context.read<AccountListController>().update(
        widget.account,
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
          'Backend mewajibkan password baru setiap kali akun diubah. '
          'Beri tahu staff password barunya.',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        ),
      ],
    );
  }
}
