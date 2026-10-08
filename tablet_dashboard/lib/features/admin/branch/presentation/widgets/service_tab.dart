import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/service_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_table.dart';
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
  // Service: nama, harga, deskripsi, status, aksi
  static const _serviceFlex = [5, 3, 4, 3, 4];
  // Paket: nama, isi paket, harga, status, aksi
  static const _packageFlex = [5, 6, 3, 3, 4];
  static const _newRow = '';

  // Backend menolak harga di bawah Rp 1.000
  static const _minPrice = 1000;

  // Baris yang sedang diedit: id layanan, [_newRow] = baris tambah baru
  String? _editing;
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();

  // Isi paket yang dipilih, null = belum diubah (deskripsi lama tetap)
  List<String>? _picked;
  bool _active = true;
  bool _busy = false;

  bool get _isPackage => widget.type == ServiceType.package;
  List<int> get _flex => _isPackage ? _packageFlex : _serviceFlex;

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
    _picked = null;
    _active = item?.active ?? true;
  });

  void _cancel() => setState(() => _editing = null);

  // Nama service di deskripsi paket "Cukur Rambut + Keramas"
  static List<String> _itemsOf(String text, List<ServiceItem> services) {
    final names = {
      for (final part in text.split('+'))
        if (part.trim().isNotEmpty) part.trim().toLowerCase(),
    };
    return [
      for (final service in services)
        if (names.contains(service.name.toLowerCase())) service.name,
    ];
  }

  Future<void> _save(ServiceItem? item) async {
    final label = widget.type.label;
    final name = _name.text.trim();
    final price = ThousandsFormatter.parse(_price.text);
    final picked = _picked;
    final description = picked != null
        ? picked.join(' + ')
        : _description.text.trim();
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
      columns: _isPackage
          ? const ['NAMA PAKET', 'PAKET TERDAFTAR', 'HARGA', 'STATUS', 'AKSI']
          : const ['SERVICE', 'HARGA', 'DESKRIPSI', 'STATUS', 'AKSI'],
      endColumns: _isPackage ? const {2} : const {},
      headerColor: _isPackage ? AppColor.surfaceSubtle : AppColor.goldSoft,
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
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColor.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
    ),
    child: AppIcon(ServiceIcon.of(item), size: 20, color: AppColor.ink),
  );

  Widget _descriptionText(ServiceItem item) => Text(
    item.description ?? '-',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
  );

  Widget _row(ServiceItem item) {
    final actions = RowActions(
      editAsset: _isPackage
          ? AppAsset.editPackageIcon
          : AppAsset.editServiceIcon,
      onEdit: () => _startEdit(item),
      onDelete: () => _delete(item),
    );
    final name = Text(
      item.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.bodyBold,
    );

    return BranchTableRow(
      flex: _flex,
      children: _isPackage
          ? [
              name,
              _descriptionText(item),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  PriceFormat.full(item.price),
                  style: AppTextStyle.bodyBold,
                ),
              ),
              ActiveBadge(active: item.active),
              actions,
            ]
          : [
              Row(
                children: [
                  _icon(item),
                  const SizedBox(width: 12),
                  Flexible(child: name),
                ],
              ),
              Text(
                PriceFormat.full(item.price),
                style: AppTextStyle.bodyBold.copyWith(color: AppColor.gold),
              ),
              _descriptionText(item),
              ActiveBadge(active: item.active),
              actions,
            ],
    );
  }

  Widget _editRow(ServiceItem? item) {
    final nameField = RowTextField(
      controller: _name,
      hint: _isPackage ? 'Nama paket' : 'Nama service',
      autofocus: item == null,
    );
    // Layanan baru selalu aktif
    final status = item == null
        ? const ActiveBadge(active: true)
        : ActiveSelect(
            active: _active,
            onChanged: (value) => setState(() => _active = value),
          );
    final actions = RowEditActions(
      busy: _busy,
      onSave: () => _save(item),
      onCancel: _cancel,
    );

    if (_isPackage) {
      final services = context.watch<ServiceListController>().all;
      return BranchTableRow(
        flex: _flex,
        color: AppColor.warningSoft,
        children: [
          nameField,
          _PackageItemsSelect(
            services: services,
            picked: _picked ?? _itemsOf(_description.text, services),
            onChanged: (value) => setState(() => _picked = value),
          ),
          MoneyField(controller: _price),
          status,
          actions,
        ],
      );
    }

    return BranchTableRow(
      flex: _flex,
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
            Expanded(child: nameField),
          ],
        ),
        MoneyField(controller: _price),
        RowTextField(controller: _description, hint: 'Deskripsi singkat'),
        status,
        actions,
      ],
    );
  }
}

// "3 Terpilih": isi paket dari service cabang, menu tetap terbuka saat dicentang
class _PackageItemsSelect extends StatelessWidget {
  const _PackageItemsSelect({
    required this.services,
    required this.picked,
    required this.onChanged,
  });

  final List<ServiceItem> services;

  // Nama service yang dipilih
  final List<String> picked;
  final ValueChanged<List<String>> onChanged;

  // Urutan isi paket ikut urutan service
  void _toggle(ServiceItem service) {
    final chosen = {...picked};
    if (!chosen.remove(service.name)) chosen.add(service.name);
    onChanged([
      for (final s in services)
        if (chosen.contains(s.name)) s.name,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColor.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColor.border),
          ),
        ),
      ),
      menuChildren: [
        if (services.isEmpty)
          MenuItemButton(
            child: Text(
              'Belum ada service di cabang ini',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
          ),
        for (final service in services)
          MenuItemButton(
            closeOnActivate: false,
            onPressed: () => _toggle(service),
            leadingIcon: SizedBox(
              width: 16,
              child: picked.contains(service.name)
                  ? const AppIcon(AppAsset.checkIcon, size: 14, tint: false)
                  : null,
            ),
            child: Text(service.name, style: AppTextStyle.bodyMedium),
          ),
      ],
      builder: (context, controller, _) => InkWell(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.borderStrong),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  picked.isEmpty
                      ? 'Pilih service'
                      : '${picked.length} Terpilih',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(
                    color: picked.isEmpty ? AppColor.inkFaint : AppColor.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColor.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
