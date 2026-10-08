import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/employee_list/domain/entities/employee.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/provider/employee_list_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/back_text_button.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/select_box.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tambah Karyawan: capster (nama + foto) atau akun kasir / mitra
// (nama + email). Field lain belum ada di backend, jadi tidak ditampilkan
class EmployeeCreateScreen extends StatefulWidget {
  const EmployeeCreateScreen({super.key});

  @override
  State<EmployeeCreateScreen> createState() => _EmployeeCreateScreenState();
}

class _EmployeeCreateScreenState extends State<EmployeeCreateScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Urutan pilihan jabatan seperti desain
  static const _roles = [
    EmployeeRole.cashier,
    EmployeeRole.capster,
    EmployeeRole.mitra,
  ];

  final _name = TextEditingController();
  final _email = TextEditingController();
  EmployeeRole? _role;
  Branch? _branch;
  PickedPhoto? _photo;
  bool _busy = false;
  String? _error;

  bool get _isCapster => _role == EmployeeRole.capster;
  bool get _isAccount => _role != null && !_isCapster;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await PhotoPicker.pick(maxSide: 720);
      if (photo != null && mounted) setState(() => _photo = photo);
    } on PhotoPickerException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
    }
  }

  // Ganti jabatan: cabang yang sudah punya jabatan itu dikosongkan
  void _setRole(EmployeeRole role) {
    final list = context.read<EmployeeListController>();
    setState(() {
      _role = role;
      final branch = _branch;
      if (branch != null && list.taken(branch.id, role)) _branch = null;
    });
  }

  String? _validate(EmployeeListController list) {
    final role = _role;
    final branch = _branch;
    if (role == null) return 'Pilih jabatan';
    if (branch == null) return 'Pilih cabang';
    if (_name.text.trim().length < 3) return 'Nama minimal 3 huruf';
    if (_isAccount && !_emailPattern.hasMatch(_email.text.trim())) {
      return 'Format email tidak valid';
    }
    if (list.taken(branch.id, role)) {
      return '${branch.name} sudah punya ${role.label}';
    }
    return null;
  }

  Future<void> _submit() async {
    final list = context.read<EmployeeListController>();
    final invalid = _validate(list);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    final name = _name.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = _isCapster
        ? await list.createCapster(
            branchId: _branch!.id,
            name: name,
            photo: _photo,
          )
        : await list.createAccount(
            branchId: _branch!.id,
            name: name,
            email: _email.text.trim(),
            role: _role!,
          );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error != null) return;
    AppToast.show(context, 'Karyawan $name ditambahkan');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<EmployeeListController>();

    return Material(
      color: AppColor.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: BackTextButton(),
            ),
            const SizedBox(height: 20),
            const Text('Tambah Karyawan', style: AppTextStyle.h1),
            Text(
              'Lengkapi biodata dan informasi pekerjaan karyawan baru.',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _biodata()),
                const SizedBox(width: 20),
                Expanded(child: _job(list)),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              MessageBox(message: _error!),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.maybePop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    side: const BorderSide(color: AppColor.borderStrong),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.gold,
                          ),
                        )
                      : const Text('Simpan Karyawan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      style: AppTextStyle.title.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _biodata() {
    final photo = _photo;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Biodata Karyawan'),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: photo != null && _isCapster
                    ? Image.memory(
                        photo.bytes,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : const AppIcon(AppAsset.cameraIcon, size: 24, tint: false),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foto Karyawan', style: AppTextStyle.label),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: _isCapster && !_busy ? _pickPhoto : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.ink,
                        side: const BorderSide(color: AppColor.borderStrong),
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: Opacity(
                        opacity: _isCapster ? 1 : 0.4,
                        child: const AppIcon(
                          AppAsset.uploadIcon,
                          size: 14,
                          tint: false,
                        ),
                      ),
                      label: Text(photo == null ? 'Unggah Foto' : 'Ganti Foto'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isCapster
                          ? 'JPG atau PNG'
                          : 'Foto hanya untuk jabatan Capster',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FieldLabel('Nama Lengkap', required: true),
          TextField(
            controller: _name,
            enabled: !_busy,
            style: AppTextStyle.body,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama lengkap',
            ),
          ),
          // Akun kasir / mitra login pakai email
          if (_isAccount) ...[
            const SizedBox(height: 14),
            const FieldLabel('Email', required: true),
            TextField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyle.body,
              decoration: const InputDecoration(hintText: 'nama@email.com'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _job(EmployeeListController list) {
    final role = _role;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Informasi Pekerjaan'),
          const FieldLabel('Jabatan', required: true),
          SelectBox<EmployeeRole>(
            value: role,
            options: _roles,
            labelOf: (r) => r.label,
            hint: 'Pilih jabatan',
            onChanged: _busy ? null : _setRole,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Cabang', required: true),
          SelectBox<Branch>(
            value: _branch,
            options: list.branches,
            labelOf: (branch) => role != null && list.taken(branch.id, role)
                ? '${branch.name} (sudah ada ${role.label})'
                : branch.name,
            enabledOf: (branch) => role == null || !list.taken(branch.id, role),
            hint: list.loading ? 'Memuat cabang...' : 'Pilih cabang',
            onChanged: _busy
                ? null
                : (branch) => setState(() => _branch = branch),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.warningSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIcon(
                  AppAsset.infoIcon,
                  size: 16,
                  color: AppColor.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    switch (role) {
                      null =>
                        'Capster tampil di kasir dan aplikasi pelanggan. '
                            'Kasir dan Mitra mendapat akun login tablet.',
                      EmployeeRole.capster =>
                        'Capster baru langsung aktif dan bisa dipilih '
                            'pelanggan di cabang ini.',
                      _ =>
                        'Akun login tablet cabang ini, password awal = '
                            'password default staff. Maks. 1 Kasir dan '
                            '1 Mitra per cabang.',
                    },
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
