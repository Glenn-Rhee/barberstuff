import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_panel.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_tab_layout.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/service_card.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Tab "Pesanan Langsung": katalog toko di kiri, pesanan di kanan
class WalkInView extends StatelessWidget {
  const WalkInView({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final order = context.watch<OrderController>();

    return OrderTabLayout(
      panel: const OrderPanel(),
      children: [
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
              Pill(
                label: type.label,
                selected: catalog.type == type,
                onTap: () => catalog.setType(type),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _catalogBody(catalog, order)),
        const SizedBox(height: 12),
        // Tanpa jumlah item: meta.total_data dari API tidak ikut filter nama
        PaginationBar(
          page: catalog.page - 1, // halaman API mulai dari 1
          pageCount: catalog.totalPages,
          onChanged: (page) => catalog.setPage(page + 1),
        ),
      ],
    );
  }

  Widget _catalogBody(CatalogController catalog, OrderController order) {
    if (catalog.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat layanan',
        message: catalog.error!,
        onRetry: catalog.refresh,
      );
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
      itemBuilder: (_, index) => ServiceCard(
        item: catalog.services[index],
        qty: order.qtyOf(catalog.services[index]),
        onAdd: () => order.add(catalog.services[index]),
      ),
    );
  }
}
