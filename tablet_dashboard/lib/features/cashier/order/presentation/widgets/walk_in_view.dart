import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/selected_customer_banner.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_panel.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_tab_layout.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/service_card.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Tab "Pesanan Langsung": katalog toko di kiri, pesanan di kanan
class WalkInView extends StatelessWidget {
  const WalkInView({super.key});

  // Tap kartu: tambah ke keranjang, atau keluarkan kalau sudah dipilih
  void _toggle(BuildContext context, ServiceItem item) {
    final order = context.read<OrderController>();
    if (order.contains(item)) {
      order.remove(item);
      return;
    }
    if (order.add(item) == CartChange.replaced) {
      AppToast.show(
        context,
        '1 pelanggan cuma 1 layanan, keranjang diganti ${item.name}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final order = context.watch<OrderController>();
    final customer = order.customer;

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
            for (final filter in CatalogFilter.values) ...[
              const SizedBox(width: 8),
              Pill(
                label: filter.label,
                selected: catalog.filter == filter,
                onTap: () => catalog.setFilter(filter),
              ),
            ],
          ],
        ),
        if (customer != null) ...[
          const SizedBox(height: 12),
          SelectedCustomerBanner(
            customer: customer,
            onClear: order.clearCustomer,
          ),
        ],
        const SizedBox(height: 16),
        Expanded(child: _catalogBody(context, catalog, order)),
        const SizedBox(height: 12),
        PaginationBar(
          page: catalog.page - 1, // halaman mulai dari 1
          pageCount: catalog.totalPages,
          onChanged: (page) => catalog.setPage(page + 1),
        ),
      ],
    );
  }

  Widget _catalogBody(
    BuildContext context,
    CatalogController catalog,
    OrderController order,
  ) {
    if (catalog.loading) {
      return const SkeletonGrid(crossAxisCount: 4, mainAxisExtent: 190);
    }
    if (catalog.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat layanan',
        message: catalog.error!,
        onRetry: catalog.refresh,
      );
    }
    final services = catalog.services;
    if (services.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'Layanan tidak ditemukan',
        message: catalog.query.isEmpty
            ? 'Toko ini belum punya ${catalog.filter.label.toLowerCase()} yang aktif.'
            : 'Tidak ada hasil untuk "${catalog.query}".',
      );
    }

    return RefreshIndicator(
      onRefresh: catalog.refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 190,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (_, index) {
          final item = services[index];
          return ServiceCard(
            item: item,
            selected: order.contains(item),
            onTap: () => _toggle(context, item),
          );
        },
      ),
    );
  }
}
