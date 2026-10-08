import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/capster_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_table.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';

// Tab Capster: daftar, tambah / ubah di baris tabel, pindah cabang, hapus
class CapsterTab extends StatefulWidget {
  const CapsterTab({super.key});

  @override
  State<CapsterTab> createState() => _CapsterTabState();
}

class _CapsterTabState extends State<CapsterTab> {
  static const _flex = [7, 2, 3, 2, 6];
  static const _newRow = '';

  // Baris yang sedang diedit: id capster, [_newRow] = baris tambah baru
  String? _editing;
  final _name = TextEditingController();
  bool _active = true;
  PickedPhoto? _photo;
  bool _busy = false;

  // Capster yang sedang dipindah + cabang tujuannya
  String? _moving;
  Branch? _target;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _startEdit(Capster? capster) => setState(() {
    _moving = null;
    _editing = capster?.id ?? _newRow;
    _name.text = capster?.name ?? '';
    _active = capster?.active ?? true;
    _photo = null;
  });

  void _cancel() => setState(() => _editing = null);

  void _startMove(Capster capster) => setState(() {
    _editing = null;
    _moving = capster.id;
    _target = null;
  });

  void _cancelMove() => setState(() => _moving = null);

  Future<void> _move(Capster capster) async {
    final target = _target;
    if (target == null) {
      AppToast.show(context, 'Pilih cabang tujuan dulu', error: true);
      return;
    }
    final list = context.read<CapsterListController>();
    setState(() => _busy = true);
    final error = await list.move(capster, target.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      AppToast.show(context, error, error: true);
      return;
    }
    setState(() => _moving = null);
    AppToast.show(context, '${capster.name} dipindah ke ${target.name}');
  }

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
        onChanged: list.setSort,
      ),
      columns: const ['NAMA KARYAWAN', 'POSISI', 'STATUS', 'RATING', 'AKSI'],
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
        for (final capster in visible) ...[
          if (_editing == capster.id) _editRow(capster) else _row(capster),
          if (_moving == capster.id) _moveRow(capster),
        ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capster.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyBold,
                  ),
                  Text(
                    'ID: ${_shortId(capster.id)}',
                    maxLines: 1,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const _Position(),
        ActiveBadge(active: capster.active),
        _Rating(value: capster.rating),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _MoveButton(onTap: () => _startMove(capster))),
            const SizedBox(width: 8),
            RowActions(
              onEdit: () => _startEdit(capster),
              onDelete: () => _delete(capster),
            ),
          ],
        ),
      ],
    );
  }

  // Baris krem di bawah capster: pilih cabang tujuan lalu Simpan
  Widget _moveRow(Capster capster) {
    final storeId = context.read<CapsterListController>().storeId;
    final branches = [
      for (final branch in context.watch<BranchListController>().all)
        if (branch.id != storeId) branch,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColor.goldSoft,
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: [
          Text('Pindah cabang', style: AppTextStyle.label),
          const SizedBox(width: 12),
          _TargetSelect(
            branches: branches,
            value: _target,
            onChanged: (branch) => setState(() => _target = branch),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setelah disimpan, capster pindah ke cabang tujuan dan '
              'hilang dari daftar cabang ini, bukan dihapus.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
          ),
          const SizedBox(width: 12),
          RowEditActions(
            busy: _busy,
            onSave: () => _move(capster),
            onCancel: _cancelMove,
          ),
        ],
      ),
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
        const _Position(),
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

// "⇄ Pindah Cabang" di kolom aksi
class _MoveButton extends StatelessWidget {
  const _MoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColor.goldSoft,
        side: const BorderSide(color: AppColor.goldBorder),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyle.label,
      ),
      icon: const Icon(Icons.swap_horiz, size: 16),
      label: const Text('Pindah Cabang', maxLines: 1),
    );
  }
}

// Pilihan cabang tujuan, cabang yang sedang dibuka tidak ikut
class _TargetSelect extends StatelessWidget {
  const _TargetSelect({
    required this.branches,
    required this.value,
    required this.onChanged,
  });

  final List<Branch> branches;
  final Branch? value;
  final ValueChanged<Branch> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Branch>(
      tooltip: 'Pilih cabang tujuan',
      // Di atas toast, bukan di dalam navigator cabang
      useRootNavigator: true,
      position: PopupMenuPosition.under,
      enabled: branches.isNotEmpty,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final branch in branches)
          PopupMenuItem(
            value: branch,
            child: Text(branch.name, style: AppTextStyle.body),
          ),
      ],
      child: Container(
        width: 220,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value?.name ??
                    (branches.isEmpty
                        ? 'Tidak ada cabang lain'
                        : 'Pilih cabang tujuan'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body.copyWith(
                  color: value == null ? AppColor.inkSoft : AppColor.ink,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

// Id pendek untuk dibaca admin, mis. "269971FF"
String _shortId(String id) =>
    (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();

// Backend belum punya posisi capster, semua tercatat sebagai Capster
class _Position extends StatelessWidget {
  const _Position();

  @override
  Widget build(BuildContext context) {
    return Text('Capster', style: AppTextStyle.caption);
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
        Text(
          value.toStringAsFixed(1),
          style: AppTextStyle.bodyBold.copyWith(color: AppColor.gold),
        ),
      ],
    );
  }
}
