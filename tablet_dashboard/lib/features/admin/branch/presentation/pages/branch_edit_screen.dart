import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_banner.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_form_fields.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_map.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/back_text_button.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Edit Cabang: tiap field disimpan sendiri lewat PATCH /store/{id}
class BranchEditScreen extends StatefulWidget {
  const BranchEditScreen({super.key});

  @override
  State<BranchEditScreen> createState() => _BranchEditScreenState();
}

class _BranchEditScreenState extends State<BranchEditScreen> {
  // Field non-teks yang sedang disimpan, mis. 'photo', 'open', 'map'
  String? _saving;

  // Titik baru yang belum disimpan
  double? _latitude;
  double? _longitude;

  BranchDetailController get _detail => context.read<BranchDetailController>();

  // Simpan lalu kabari menu lain. Balikin pesan error untuk field teks
  Future<String?> _save(
    Future<String?> Function() action, {
    String? key,
    String message = 'Perubahan disimpan',
  }) async {
    if (key != null) setState(() => _saving = key);
    final error = await action();
    if (!mounted) return error;
    if (key != null) setState(() => _saving = null);
    if (error != null) {
      if (key != null) AppToast.show(context, error, error: true);
      return error;
    }
    AppToast.show(context, message);
    return null;
  }

  Future<void> _changePhoto() async {
    final PickedPhoto photo;
    try {
      final picked = await PhotoPicker.pick();
      if (picked == null) return;
      photo = picked;
    } on PhotoPickerException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
      return;
    }
    if (!mounted) return;
    await _save(
      () => _detail.changeBanner(photo),
      key: 'photo',
      message: 'Foto cabang diganti',
    );
  }

  Future<void> _changeClock({required bool open}) async {
    final branch = _detail.branch;
    final picked = await pickClock(
      context,
      open ? branch.openHour : branch.closeHour,
    );
    if (picked == null || !mounted) return;
    final openHour = open ? picked : branch.openHour;
    final closeHour = open ? branch.closeHour : picked;
    if (openHour != null &&
        closeHour != null &&
        DateFormatId.minutesOf(openHour) >= DateFormatId.minutesOf(closeHour)) {
      AppToast.show(context, 'Jam tutup harus setelah jam buka', error: true);
      return;
    }
    await _save(
      () => open
          ? _detail.update(openHour: picked)
          : _detail.update(closeHour: picked),
      key: open ? 'open' : 'close',
      message: open ? 'Jam buka jadi $picked' : 'Jam tutup jadi $picked',
    );
  }

  Future<void> _changeStatus(bool open) async {
    if (!open) {
      final confirmed = await confirmDialog(
        context,
        title: 'Tutup cabang?',
        message:
            'Cabang tampil "Tutup" di kasir dan aplikasi pelanggan sampai '
            'dibuka lagi.',
        confirmLabel: 'Tutup Cabang',
        danger: true,
      );
      if (!confirmed || !mounted) return;
    }
    await _save(
      () => _detail.update(open: open),
      key: 'status',
      message: open ? 'Cabang dibuka' : 'Cabang ditutup',
    );
  }

  Future<void> _saveMap() async {
    final lat = _latitude, long = _longitude;
    if (lat == null || long == null) return;
    final error = await _save(
      () => _detail.update(latitude: lat, longitude: long),
      key: 'map',
      message: 'Titik peta disimpan',
    );
    if (error == null && mounted) {
      setState(() => _latitude = _longitude = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<BranchDetailController>();
    final branch = detail.branch;

    return Material(
      color: AppColor.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackTextButton(),
            const SizedBox(height: 20),
            const Text('Informasi Cabang', style: AppTextStyle.h1),
            Text(
              'Lihat dan ubah informasi ${branch.name} sesuai kebutuhan.',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
            if (detail.error != null) ...[
              const SizedBox(height: 16),
              ErrorBar(
                message: 'Data terbaru gagal dimuat: ${detail.error}',
                onRetry: detail.load,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _infoCard(branch)),
                const SizedBox(width: 20),
                Expanded(child: _locationCard(branch)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(Branch branch) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Informasi Cabang', style: AppTextStyle.h3),
          const SizedBox(height: 16),
          InlineEditField(
            label: 'Nama Cabang',
            value: branch.name,
            onSave: (value) => _save(() => _detail.update(name: value)),
          ),
          const SizedBox(height: 14),
          InlineEditField(
            label: 'Nomor Telepon',
            value: branch.phone,
            keyboardType: TextInputType.phone,
            validator: validatePhone,
            onSave: (value) => _save(() => _detail.update(phone: value)),
          ),
          const SizedBox(height: 14),
          InlineEditField(
            label: 'Deskripsi',
            value: branch.description,
            maxLines: 4,
            allowEmpty: true,
            onSave: (value) => _save(() => _detail.update(description: value)),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Tipe Cabang'),
          _Choices<BranchType>(
            values: BranchType.values,
            selected: branch.type,
            labelOf: (t) => t.label,
            busy: _saving == 'type',
            onChanged: (type) =>
                _save(() => _detail.update(type: type), key: 'type'),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Status Cabang'),
          _Choices<bool>(
            values: const [true, false],
            selected: branch.open,
            labelOf: (open) => open ? 'Buka' : 'Tutup',
            busy: _saving == 'status',
            onChanged: _changeStatus,
          ),
        ],
      ),
    );
  }

  Widget _locationCard(Branch branch) {
    final changedMap = _latitude != null && _longitude != null;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Foto Cabang'),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 240,
                  child: BranchBanner(
                    url: branch.bannerUrl,
                    height: 140,
                    radius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _saving == 'photo' ? null : _changePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.inkSoft,
                  side: const BorderSide(color: AppColor.borderStrong),
                ),
                icon: _saving == 'photo'
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit, size: 18),
                label: const Text('Ganti Foto'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClockField(
                  label: 'Jam Buka',
                  value: branch.openHour,
                  icon: Icons.edit,
                  busy: _saving == 'open',
                  onTap: () => _changeClock(open: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ClockField(
                  label: 'Jam Tutup',
                  value: branch.closeHour,
                  icon: Icons.edit,
                  busy: _saving == 'close',
                  onTap: () => _changeClock(open: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Lokasi Cabang', style: AppTextStyle.h3),
          const SizedBox(height: 12),
          InlineEditField(
            label: 'Alamat Lengkap',
            value: branch.address,
            maxLines: 3,
            onSave: (value) => _save(() => _detail.update(address: value)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: FieldLabel('Titik Peta (GPS)')),
              if (changedMap) ...[
                TextButton(
                  onPressed: _saving == 'map'
                      ? null
                      : () => setState(() => _latitude = _longitude = null),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.inkSoft,
                  ),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: _saving == 'map' ? null : _saveMap,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                  child: const Text('Simpan Titik'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          BranchMapPicker(
            // Key ikut titik tersimpan supaya peta pindah setelah disimpan
            key: ValueKey('${branch.latitude},${branch.longitude}'),
            latitude: _latitude ?? branch.latitude,
            longitude: _longitude ?? branch.longitude,
            height: 280,
            addressOf: () => branch.address ?? '',
            onChanged: (lat, long) => setState(() {
              _latitude = lat;
              _longitude = long;
            }),
          ),
        ],
      ),
    );
  }
}

// Pilihan bulat yang langsung disimpan saat ditekan
class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.busy,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final bool busy;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final value in values) ...[
          Pill(
            label: labelOf(value),
            selected: value == selected,
            style: PillStyle.soft,
            height: 40,
            onTap: busy || value == selected ? null : () => onChanged(value),
          ),
          const SizedBox(width: 8),
        ],
        if (busy)
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
