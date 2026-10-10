import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
<<<<<<< HEAD
import 'package:tablet_dashboard/features/cashier/customer/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_history_view.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/walk_in_view.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/pages/scan_booking_screen.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/bookings_view.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
=======
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_customer_history/presentation/widgets/customer_history_view.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/widgets/bookings_view.dart';
import 'package:tablet_dashboard/features/cashier/order_scan/presentation/pages/scan_booking_screen.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/widgets/walk_in_view.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
import 'package:tablet_dashboard/shared/widgets/buttons/header_action_button.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/refresh_button.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';

// Halaman Kasir: Pesanan Langsung, Dari Reservasi, dan Histori Pelanggan
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  // Hit ulang data tab yang sedang dibuka
  Future<void> _refresh(BuildContext context, OrderTab tab) async {
    switch (tab) {
      case OrderTab.walkIn:
        final catalog = context.read<CatalogController>();
        await Future.wait([catalog.refresh(), catalog.loadCapsters()]);
      case OrderTab.reservation:
        await context.read<BookingsController>().refresh();
      case OrderTab.history:
        await context.read<CustomerHistoryController>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final tab = nav.orderTab;
    final history = tab == OrderTab.history;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: history ? 'Histori Pelanggan' : 'Kasir',
            subtitle: history
                ? 'Member pakai aplikasi, reguler didaftarkan kasir.'
                : 'Kelola informasi dan layanan di setiap cabang.',
            onBack: history ? () => nav.openOrder(OrderTab.walkIn) : null,
            actions: [
              switch (tab) {
                OrderTab.walkIn => HeaderActionButton(
                  icon: AppAsset.personIcon,
                  label: 'Histori Pelanggan',
                  onTap: () => nav.openOrder(OrderTab.history),
                ),
                OrderTab.reservation => HeaderActionButton(
                  icon: AppAsset.scanIcon,
                  label: 'Scan Barcode',
                  onTap: () => openScanBooking(context),
                ),
                OrderTab.history => const SizedBox.shrink(),
              },
              RefreshButton(onRefresh: () => _refresh(context, tab)),
              const StoreSelector(),
              const StoreOpenChip(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: switch (tab) {
              OrderTab.walkIn => const WalkInView(),
              OrderTab.reservation => const BookingsView(),
              OrderTab.history => const CustomerHistoryView(),
            },
          ),
        ],
      ),
    );
  }
}
