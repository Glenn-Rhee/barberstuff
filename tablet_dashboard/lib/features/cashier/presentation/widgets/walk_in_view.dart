import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../shared/models/service_item.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pagination_bar.dart';
import '../../../../shared/widgets/pill.dart';
import '../pages/kasir_page.dart';
import '../provider/catalog_controller.dart';
import '../provider/order_controller.dart';
import 'order_panel.dart';

/// "Pesanan Langsung": the store's service catalog from the API on the left,
/// the order being rung up on the right.
class WalkInView extends StatelessWidget {
  const WalkInView({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final order = context.watch<OrderController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: KasirTabs()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hint: 'Cari service atau paket...',
                      initialValue: catalog.query,
                      onChanged: catalog.setQuery,
                    ),
                  ),
                  for (final type in ServiceType.values) ...[
                    const SizedBox(width: 8),
                    Pill(label: type.label, selected: catalog.type == type, onTap: () => catalog.setType(type)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _catalogBody(catalog, order)),
              const SizedBox(height: 12),
              // No item count here: the API's meta.total_data ignores the name filter.
              PaginationBar(
                page: catalog.page - 1, // the API pages from 1
                pageCount: catalog.totalPages,
                onChanged: (page) => catalog.setPage(page + 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const SizedBox(width: kasirPanelWidth, child: OrderPanel()),
      ],
    );
  }

  Widget _catalogBody(CatalogController catalog, OrderController order) {
    if (catalog.loading) return const Center(child: CircularProgressIndicator());
    if (catalog.error != null) {
      return _CatalogError(message: catalog.error!, onRetry: catalog.refresh);
    }
    if (catalog.services.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: '${catalog.type.label} tidak ditemukan',
        message: catalog.query.isEmpty
            ? 'Toko ini belum punya ${catalog.type.label.toLowerCase()} yang aktif.'
            : 'Tidak ada hasil untuk "${catalog.query}".',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 172,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: catalog.services.length,
      itemBuilder: (_, index) => _ServiceCard(
        item: catalog.services[index],
        qty: order.qtyOf(catalog.services[index]),
        onAdd: () => order.add(catalog.services[index]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.qty, required this.onAdd});

  final ServiceItem item;
  final int qty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColor.surfaceMuted, shape: BoxShape.circle),
                  child: Icon(
                    item.type == ServiceType.package ? Icons.workspace_premium_outlined : Icons.content_cut,
                    size: 20,
                    color: AppColor.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyStrong,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    PriceFormat.full(item.price),
                    style: AppTextStyle.bodyStrong.copyWith(color: AppColor.gold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: TextButton(
                    style: softGoldStyle(),
                    onPressed: onAdd,
                    child: const Text('+ Tambah', style: AppTextStyle.label),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (qty > 0)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(color: AppColor.gold, borderRadius: BorderRadius.circular(999)),
              child: Text('$qty', style: AppTextStyle.overline.copyWith(color: Colors.white)),
            ),
          ),
      ],
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColor.inkFaint),
          const SizedBox(height: 12),
          Text('Gagal memuat layanan', style: AppTextStyle.bodyStrong),
          const SizedBox(height: 2),
          Text(message, style: AppTextStyle.caption, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
