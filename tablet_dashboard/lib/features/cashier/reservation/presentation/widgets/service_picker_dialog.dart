import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';

// Pilih layanan dari katalog toko untuk ditambah ke booking
Future<ServiceItem?> showServicePicker(BuildContext context) {
  return showDialog<ServiceItem>(
    context: context,
    builder: (_) => const _ServicePickerDialog(),
  );
}

class _ServicePickerDialog extends StatelessWidget {
  const _ServicePickerDialog();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();

    return AlertDialog(
      title: const Text('Tambah Layanan / Paket', style: AppTextStyle.title),
      content: SizedBox(
        width: 520,
        height: 440,
        child: Column(
          children: [
            AppSearchField(
              hint: 'Cari service atau paket...',
              initialValue: catalog.query,
              onChanged: catalog.setQuery,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final type in ServiceType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type.label, style: AppTextStyle.label),
                      selected: catalog.type == type,
                      showCheckmark: false,
                      onSelected: (_) => catalog.setType(type),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch ((catalog.loading, catalog.error)) {
                (true, _) => const Center(child: CircularProgressIndicator()),
                (_, final String error) => EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat layanan',
                  message: error,
                ),
                _ when catalog.services.isEmpty => const EmptyState(
                  icon: Icons.search_off,
                  title: 'Tidak ada hasil',
                  message: 'Coba kata kunci lain.',
                ),
                _ => ListView.separated(
                  itemCount: catalog.services.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, index) {
                    final item = catalog.services[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColor.surfaceMuted,
                        child: item.type == ServiceType.package
                            ? Icon(
                                Icons.workspace_premium_outlined,
                                size: 18,
                                color: AppColor.ink,
                              )
                            : AppIcon(
                                AppAsset.scissorsIcon,
                                size: 18,
                                color: AppColor.ink,
                              ),
                      ),
                      title: Text(item.name, style: AppTextStyle.bodyBold),
                      subtitle: item.description == null
                          ? null
                          : Text(
                              item.description!,
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
            if (catalog.totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Halaman ${catalog.page} dari ${catalog.totalPages}',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ),
          ],
        ),
      ),
      actions: const [DialogCancelButton()],
    );
  }
}
