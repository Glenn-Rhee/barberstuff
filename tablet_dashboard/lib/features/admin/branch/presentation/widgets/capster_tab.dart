import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/capster_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_table.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';

// Tab Capster: daftar, tambah / ubah di baris tabel, hapus
class CapsterTab extends StatefulWidget {
  const CapsterTab({super.key});

  @override
  State<CapsterTab> createState() => _CapsterTabState();
}

class _CapsterTabState extends State<CapsterTab> {
  static const _flex = [6, 2, 2, 3];
  static const _newRow = '';

  // Baris yang sedang diedit: id capster, [_newRow] = baris tambah baru
  String? _editing;
  final _name = TextEditingController();
  bool _active = true;
  PickedPhoto? _photo;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _startEdit(Capster? capster) => setState(() {
    _editing = capster?.id ?? _newRow;
    _name.text = capster?.name ?? '';
    _active = capster?.active ?? true;
    _photo = null;
  });

  void _cancel() => setState(() => _editing = null);

  Future<void> _pickPhoto() async {
    try {
      final photo = await PhotoPicker.pick(maxSide: 720);
      if (photo != null && mounted) setState(() => _photo = photo);
    } on PhotoPickerException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
    }
  }

  Future<void> _save(Capster? capster) async {
    final name = _name.text.trim();
    if (name.length < 3) {
      AppToast.show(context, 'Nama capster minimal 3 huruf', error: true);
      return;
    }
    // Tidak ada yang berubah, backend menolak update kosong
    if (capster != null &&
        name == capster.name &&
        _active == capster.active &&
        _photo == null) {
      _cancel();
      return;
    }
    final list = context.read<CapsterListController>();
    setState(() => _busy = true);
    final error = capster == null
        ? await list.create(name: name, photo: _photo)
        : await list.update(
            capster,
            name: name == capster.name ? null : name,
            active: _active == capster.active ? null : _active,
            photo: _photo,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      AppToast.show(context, error, error: true);
      return;
    }
    setState(() => _editing = null);
    AppToast.show(
      context,
      capster == null ? 'Capster $name ditambahkan' : 'Capster $name disimpan',
    );
  }

  Future<void> _delete(Capster capster) async {
    final list = context.read<CapsterListController>();
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus capster?',
      message:
          '${capster.name} tidak akan tampil lagi di kasir dan aplikasi pelanggan.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    final error = await list.delete(capster);
    if (!mounted) return;
    if (error != null) {
      AppToast.show(context, error, error: true);
      return;
    }
    AppToast.show(context, 'Capster ${capster.name} dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<CapsterListController>();
    final visible = list.visible;

    return BranchListCard(
      title: 'Daftar Capster',
      searchHint: 'Cari capster...',
      query: list.query,
      onQuery: list.setQuery,
      addLabel: 'Tambah Capster',
      onAdd: _editing == _newRow ? null : () => _startEdit(null),
      sort: DropdownChip<CapsterSort>(
        value: list.sort,
        options: CapsterSort.values,
        labelOf: (s) => s.label,
        prefix: 'Urutkan: ',
        onChanged: list.setSort,
      ),
      columns: const ['NAMA CAPSTER', 'STATUS', 'RATING', 'AKSI'],
      flex: _flex,
      loading: list.loading,
      error: list.error,
      onRetry: list.refresh,
      emptyTitle: list.all.isEmpty
          ? 'Belum ada capster'
          : 'Capster tidak ditemukan',
      emptyMessage: list.all.isEmpty
          ? 'Tambah capster pertama untuk cabang ini.'
          : 'Coba kata kunci lain.',
      page: list.page,
      pageCount: list.totalPages,
      onPage: list.setPage,
      rows: [
        if (_editing == _newRow) _editRow(null),
        for (final capster in visible)
          if (_editing == capster.id) _editRow(capster) else _row(capster),
      ],
    );
  }

  Widget _row(Capster capster) {
    return BranchTableRow(
      flex: _flex,
      children: [
        Row(
          children: [
            PersonAvatar(name: capster.name, photo: capster.photoUrl, size: 38),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                capster.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyBold,
              ),
            ),
          ],
        ),
        ActiveBadge(active: capster.active),
        _Rating(value: capster.rating),
        RowActions(
          onEdit: () => _startEdit(capster),
          onDelete: () => _delete(capster),
        ),
      ],
    );
  }

  Widget _editRow(Capster? capster) {
    final photo = _photo;

    return BranchTableRow(
      flex: _flex,
      highlight: true,
      children: [
        Row(
          children: [
            Tooltip(
              message: 'Ganti foto',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _busy ? null : _pickPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    photo != null
                        ? ClipOval(
                            child: Image.memory(
                              photo.bytes,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                            ),
                          )
                        : PersonAvatar(
                            name: _name.text.isEmpty ? '?' : _name.text,
                            photo: capster?.photoUrl,
                            size: 38,
                          ),
                    const Positioned(
                      right: -4,
                      bottom: -4,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColor.gold,
                        child: Icon(
                          Icons.photo_camera,
                          size: 12,
                          color: AppColor.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RowTextField(
                controller: _name,
                hint: 'Nama capster',
                autofocus: capster == null,
              ),
            ),
          ],
        ),
        // Capster baru selalu aktif
        capster == null
            ? const ActiveBadge(active: true)
            : ActiveSelect(
                active: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
        capster == null
            ? Text(
                'Baru',
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              )
            : _Rating(value: capster.rating),
        RowEditActions(
          busy: _busy,
          onSave: () => _save(capster),
          onCancel: _cancel,
        ),
      ],
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon(AppAsset.starIcon, size: 16, tint: false),
        const SizedBox(width: 4),
        Text(value.toStringAsFixed(1), style: AppTextStyle.bodyBold),
      ],
    );
  }
}
