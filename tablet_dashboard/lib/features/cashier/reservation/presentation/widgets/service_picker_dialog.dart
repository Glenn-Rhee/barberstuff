import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';

// Pilih 1 layanan / paket dari katalog untuk ditambahkan.
// [excludeIds] = layanan yang sudah dipakai, tidak ditampilkan (tidak bisa 2x)
Future<ServiceItem?> showServicePicker(
  BuildContext context, {
  Set<String> excludeIds = const {},
  String title = 'Tambah Layanan / Paket',
}) {
  return showDialog<ServiceItem>(
    context: context,
    builder: (_) => _ServicePickerDialog(excludeIds: excludeIds, title: title),
  );
}

class _ServicePickerDialog extends StatefulWidget {
  const _ServicePickerDialog({required this.excludeIds, required this.title});

  final Set<String> excludeIds;
  final String title;

  @override
  State<_ServicePickerDialog> createState() => _ServicePickerDialogState();
}

class _ServicePickerDialogState extends State<_ServicePickerDialog> {
  String _query = '';
  CatalogFilter _filter = CatalogFilter.all;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final keyword = _query.trim().toLowerCase();
    final items = [
      for (final item in catalog.all)
        if (_filter.accepts(item) &&
            !widget.excludeIds.contains(item.id) &&
            (keyword.isEmpty || item.name.toLowerCase().contains(keyword)))
          item,
    ];

    return AlertDialog(
      title: Text(widget.title, style: AppTextStyle.title),
      content: SizedBox(
        width: 520,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSearchField(
              hint: 'Cari service atau paket...',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final filter in CatalogFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.label, style: AppTextStyle.label),
                      selected: _filter == filter,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch ((catalog.loading, catalog.error)) {
                (true, _) => const SkeletonTiles(count: 6, avatar: false),
                (_, final String error) => EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat layanan',
                  message: error,
                ),
                _ when items.isEmpty => const EmptyState(
                  icon: Icons.search_off,
                  title: 'Tidak ada layanan',
                  message: 'Coba kata kunci atau filter lain.',
                ),
                _ => ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColor.surfaceMuted,
                        child: AppIcon(
                          ServiceIcon.of(item),
                          size: 18,
                          color: AppColor.ink,
                        ),
                      ),
                      title: Text(item.name, style: AppTextStyle.bodyBold),
                      subtitle: Text(
                        item.description ?? item.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        PriceFormat.full(item.price),
                        style: AppTextStyle.bodyBold.copyWith(
                          color: AppColor.gold,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              },
            ),
          ],
        ),
      ),
      actions: const [DialogCancelButton()],
    );
  }
}
