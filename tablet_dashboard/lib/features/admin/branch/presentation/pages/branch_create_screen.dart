import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch_draft.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_form_fields.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_map.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/back_text_button.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tambah Cabang: info toko di kiri, lokasi + peta di kanan
class BranchCreateScreen extends StatefulWidget {
  const BranchCreateScreen({super.key});

  @override
  State<BranchCreateScreen> createState() => _BranchCreateScreenState();
}

class _BranchCreateScreenState extends State<BranchCreateScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();

  PickedPhoto? _photo;
  String _openHour = '09:00';
  String _closeHour = '21:00';
  BranchType _type = BranchType.premium;
  BranchTimezone _timezone = BranchTimezone.jakarta;
  double? _latitude;
  double? _longitude;

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _description,
      _address,
      _city,
      _postalCode,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // Backend cuma punya satu kolom alamat, kota & kode pos digabung
  String get _fullAddress {
    final region = [
      _city.text.trim(),
      _postalCode.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    final street = _address.text.trim();
    return region.isEmpty ? street : '$street, $region';
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await PhotoPicker.pick();
      if (photo != null && mounted) setState(() => _photo = photo);
    } on PhotoPickerException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
    }
  }

  Future<void> _pickClock({required bool open}) async {
    final picked = await pickClock(context, open ? _openHour : _closeHour);
    if (picked == null || !mounted) return;
    setState(() => open ? _openHour = picked : _closeHour = picked);
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Nama cabang wajib diisi';
    final phone = validatePhone(_phone.text);
    if (phone != null) return phone;
    if (_photo == null) return 'Pilih foto cabang';
    if (DateFormatId.minutesOf(_openHour) >=
        DateFormatId.minutesOf(_closeHour)) {
      return 'Jam tutup harus setelah jam buka';
    }
    if (_address.text.trim().isEmpty) return 'Alamat lengkap wajib diisi';
    if (_latitude == null || _longitude == null) {
      return 'Tandai titik lokasi cabang di peta';
    }
    return null;
  }

  Future<void> _submit() async {
    final invalid = _validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    final description = _description.text.trim();
    final name = _name.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<BranchListController>().create(
      BranchDraft(
        name: name,
        phone: _phone.text.trim(),
        address: _fullAddress,
        description: description.isEmpty ? null : description,
        openHour: _openHour,
        closeHour: _closeHour,
        latitude: _latitude!,
        longitude: _longitude!,
        type: _type,
        timezone: _timezone,
      ),
      _photo!,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    AppToast.show(context, 'Cabang $name berhasil ditambahkan');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackTextButton(),
            const SizedBox(height: 20),
            const Text('Tambah Cabang', style: AppTextStyle.h1),
            Text(
              'Lengkapi informasi untuk menambahkan cabang baru',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _infoCard()),
                const SizedBox(width: 20),
                Expanded(child: _locationCard()),
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
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    side: const BorderSide(color: AppColor.ink),
                    minimumSize: const Size(110, 46),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 46),
                  ),
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.gold,
                          ),
                        )
                      : const Text('Simpan Cabang Baru'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Informasi Cabang', style: AppTextStyle.h3),
          const SizedBox(height: 16),
          const FieldLabel('Nama Cabang', required: true),
          TextField(
            controller: _name,
            style: AppTextStyle.body,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama cabang (contoh: Barberstuff Setiabudi)',
            ),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Nomor Telepon', required: true),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            style: AppTextStyle.body,
            decoration: const InputDecoration(hintText: '08xxxxxxxxxx'),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Deskripsi'),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 4,
            style: AppTextStyle.body,
            decoration: const InputDecoration(
              hintText: 'Tulis deskripsi singkat mengenai cabang ini...',
            ),
          ),
          const SizedBox(height: 14),
          const FieldLabel('Foto Cabang', required: true),
          PhotoDropZone(bytes: _photo?.bytes, onTap: _pickPhoto),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClockField(
                  label: 'Jam Buka',
                  required: true,
                  value: _openHour,
                  onTap: () => _pickClock(open: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ClockField(
                  label: 'Jam Tutup',
                  required: true,
                  value: _closeHour,
                  onTap: () => _pickClock(open: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const FieldLabel('Tipe Cabang', required: true),
          Row(
            children: [
              for (final type in BranchType.values) ...[
                Pill(
                  label: type.label,
                  selected: _type == type,
                  style: PillStyle.soft,
                  height: 40,
                  onTap: () => setState(() => _type = type),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const FieldLabel('Zona Waktu', required: true),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final zone in BranchTimezone.values)
                Pill(
                  label: zone.label,
                  selected: _timezone == zone,
                  style: PillStyle.soft,
                  height: 40,
                  onTap: () => setState(() => _timezone = zone),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Lokasi Cabang', style: AppTextStyle.h3),
          const SizedBox(height: 16),
          const FieldLabel('Alamat Lengkap', required: true),
          TextField(
            controller: _address,
            minLines: 3,
            maxLines: 4,
            style: AppTextStyle.body,
            decoration: const InputDecoration(
              hintText: 'Masukkan alamat jalan lengkap dan nomor bangunan...',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Kota'),
                    TextField(
                      controller: _city,
                      style: AppTextStyle.body,
                      decoration: const InputDecoration(hintText: 'Bandung'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Kode Pos'),
                    TextField(
                      controller: _postalCode,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      style: AppTextStyle.body,
                      decoration: const InputDecoration(
                        hintText: '40123',
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const FieldLabel('Titik Peta (GPS)', required: true),
          BranchMapPicker(
            latitude: _latitude,
            longitude: _longitude,
            height: 320,
            addressOf: () => _fullAddress,
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
