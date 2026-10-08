import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/widgets/customer_card.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_tab_layout.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/widgets/order_panel.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Histori pelanggan, pilih = dipakai di pesanan langsung
class CustomerHistoryView extends StatefulWidget {
  const CustomerHistoryView({super.key});

  @override
  State<CustomerHistoryView> createState() => _CustomerHistoryViewState();
}

class _CustomerHistoryViewState extends State<CustomerHistoryView> {
  @override
  void initState() {
    super.initState();
    // Data terbaru tiap kali histori dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final history = context.read<CustomerHistoryController>();
      history.refresh(silent: history.all.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CustomerHistoryController>();
    final selectedId = context.select<OrderController, String?>(
      (o) => o.customer?.id,
    );

    return OrderTabLayout(
      showTabs: false,
      panel: const OrderPanel(),
      children: [
        AppSearchField(
          hint: 'Cari nama atau nomor telepon pelanggan...',
          initialValue: history.query,
          onChanged: history.setQuery,
        ),
        const SizedBox(height: 16),
        Expanded(child: _body(context, history, selectedId)),
        const SizedBox(height: 12),
        PaginationBar(
          page: history.page - 1, // halaman API mulai dari 1
          pageCount: history.totalPages,
          onChanged: (page) => history.setPage(page + 1),
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    CustomerHistoryController history,
    String? selectedId,
  ) {
    if (history.loading) {
      return const SkeletonGrid(
        crossAxisCount: 3,
        mainAxisExtent: 300,
        count: 6,
        avatar: true,
      );
    }
    if (history.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat pelanggan',
        message: history.error!,
        onRetry: history.refresh,
      );
    }
    if (history.customers.isEmpty) {
      return EmptyState(
        icon: Icons.person_search_outlined,
        title: 'Pelanggan tidak ditemukan',
        message: history.query.isEmpty
            ? 'Pelanggan baru tersimpan otomatis setelah pesanan dibuat.'
            : 'Tidak ada hasil untuk "${history.query}". No HP harus persis.',
      );
    }

    return RefreshIndicator(
      onRefresh: history.refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 300,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: history.customers.length,
        itemBuilder: (_, index) {
          final customer = history.customers[index];
          return CustomerCard(
            customer: customer,
            selected: customer.id == selectedId,
            onSelect: () {
              context.read<OrderController>().setCustomer(customer);
              context.read<NavigationController>().openOrder(OrderTab.walkIn);
            },
          );
        },
      ),
    );
  }
}
