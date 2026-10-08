import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/service_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_table.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/package_items_dialog.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';
import 'package:tablet_dashboard/shared/widgets/form/money_field.dart';

// Tab Service / Paket: daftar, tambah / ubah di baris tabel, hapus
class ServiceTab extends StatefulWidget {
  const ServiceTab({super.key, required this.type});

  final ServiceType type;

  @override
  State<ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> {
  static const _flex = [4, 3, 4, 3, 4];
  static const _newRow = '';

  // Backend menolak harga di bawah Rp 1.000
  static const _minPrice = 1000;

  // Baris yang sedang diedit: id layanan, [_newRow] = baris tambah baru
  String? _editing;
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  bool _active = true;
  bool _busy = false;

  bool get _isPackage => widget.type == ServiceType.package;

  ServiceListController _list(BuildContext context, {bool listen = false}) =>
      _isPackage
      ? Provider.of<PackageListController>(context, listen: listen)
      : Provider.of<ServiceListController>(context, listen: listen);

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _startEdit(ServiceItem? item) => setState(() {
    _editing = item?.id ?? _newRow;
    _name.text = item?.name ?? '';
    _price.text = item == null ? '' : PriceFormat.plain(item.price);
    _description.text = item?.description ?? '';
    _active = item?.active ?? true;
  });

  void _cancel() => setState(() => _editing = null);

  Future<void> _pickItems() async {
    final services = context.read<ServiceListController>().all;
    final text = await showPackageItemsDialog(
      context,
      services: services,
      current: _description.text,
    );
    if (text != null) _description.text = text;
  }

  Future<void> _save(ServiceItem? item) async {
    final label = widget.type.label;
    final name = _name.text.trim();
    final price = ThousandsFormatter.parse(_price.text);
    final description = _description.text.trim();
    if (name.isEmpty) {
      AppToast.show(
        context,
        'Nama ${label.toLowerCase()} wajib diisi',
        error: true,
      );
      return;
    }
    if (price < _minPrice) {
      AppToast.show(context, 'Harga minimal Rp 1.000', error: true);
      return;
    }
    // Tidak ada yang berubah, backend menolak update kosong
    if (item != null &&
        name == item.name &&
        price == item.price &&
        description == (item.description ?? '') &&
        _active == item.active) {
      _cancel();
      return;
    }
    final list = _list(context);
    setState(() => _busy = true);
    final error = item == null
        ? await list.create(
            name: name,
            price: price,
            description: description.isEmpty ? null : description,
          )
        : await list.update(
            item,
            name: name == item.name ? null : name,
            price: price == item.price ? null : price,
            description: description == (item.description ?? '')
                ? null
                : description,
            active: _active == item.active ? null : _active,
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
      item == null ? '$label $name ditambahkan' : '$label $name disimpan',
    );
  }

  Future<void> _delete(ServiceItem item) async {
    final list = _list(context);
    final label = widget.type.label;
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus ${label.toLowerCase()}?',
      message: '${item.name} tidak akan bisa dipesan lagi di cabang ini.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    final error = await list.delete(item);
    if (!mounted) return;
    if (error != null) {
      AppToast.show(context, error, error: true);
      return;
    }
    AppToast.show(context, '$label ${item.name} dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final list = _list(context, listen: true);
    final label = widget.type.label;

    return BranchListCard(
      title: 'Daftar $label',
      searchHint: 'Cari ${label.toLowerCase()}...',
      query: list.query,
      onQuery: list.setQuery,
      addLabel: 'Tambah $label',
      onAdd: _editing == _newRow ? null : () => _startEdit(null),
      sort: DropdownChip<ServiceSort>(
        value: list.sort,
        options: ServiceSort.values,
        labelOf: (s) => s.label,
        onChanged: list.setSort,
      ),
      columns: [
        _isPackage ? 'NAMA PAKET' : 'SERVICE',
        'HARGA',
        _isPackage ? 'ISI PAKET' : 'DESKRIPSI',
        'STATUS',
        'AKSI',
      ],
      flex: _flex,
      loading: list.loading,
      error: list.error,
      onRetry: list.refresh,
      emptyTitle: list.all.isEmpty
          ? 'Belum ada ${label.toLowerCase()}'
          : '$label tidak ditemukan',
      emptyMessage: list.all.isEmpty
          ? 'Tambah ${label.toLowerCase()} pertama untuk cabang ini.'
          : 'Coba kata kunci lain.',
      page: list.page,
      pageCount: list.totalPages,
      onPage: list.setPage,
      rows: [
        if (_editing == _newRow) _editRow(null),
        for (final item in list.visible)
          if (_editing == item.id) _editRow(item) else _row(item),
      ],
    );
  }

  Widget _icon(ServiceItem item) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AppColor.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
    ),
    child: AppIcon(ServiceIcon.of(item), size: 20, color: AppColor.ink),
  );

  Widget _row(ServiceItem item) {
    return BranchTableRow(
      flex: _flex,
      children: [
        Row(
          children: [
            _icon(item),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyBold,
              ),
            ),
          ],
        ),
        Text(
          PriceFormat.full(item.price),
          style: AppTextStyle.bodyBold.copyWith(color: AppColor.gold),
        ),
        Text(
          item.description ?? '-',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
        ),
        ActiveBadge(active: item.active),
        RowActions(
          onEdit: () => _startEdit(item),
          onDelete: () => _delete(item),
        ),
      ],
    );
  }

  Widget _editRow(ServiceItem? item) {
    return BranchTableRow(
      flex: _flex,
      highlight: true,
      children: [
        Row(
          children: [
            _icon(
              item ??
                  ServiceItem(
                    id: '',
                    name: _name.text,
                    price: 0,
                    type: widget.type,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RowTextField(
                controller: _name,
                hint: _isPackage ? 'Nama paket' : 'Nama service',
                autofocus: item == null,
              ),
            ),
          ],
        ),
        MoneyField(controller: _price),
        RowTextField(
          controller: _description,
          hint: _isPackage ? 'Mis. Cukur + Keramas' : 'Deskripsi singkat',
          suffix: _isPackage
              ? IconButton(
                  tooltip: 'Pilih dari service cabang',
                  onPressed: _pickItems,
                  icon: const Icon(
                    Icons.playlist_add_check,
                    color: AppColor.gold,
                  ),
                )
              : null,
        ),
        // Layanan baru selalu aktif
        item == null
            ? const ActiveBadge(active: true)
            : ActiveSelect(
                active: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
        RowEditActions(
          busy: _busy,
          onSave: () => _save(item),
          onCancel: _cancel,
        ),
      ],
    );
  }
}
