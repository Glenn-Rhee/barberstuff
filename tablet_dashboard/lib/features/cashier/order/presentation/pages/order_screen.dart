import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/widgets/customer_history_view.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/walk_in_view.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/pages/scan_booking_screen.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/bookings_view.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';

// Halaman Kasir: Pesanan Langsung, Dari Reservasi, dan Histori Pelanggan
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

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
                OrderTab.walkIn => _HeaderButton(
                  icon: AppAsset.personIcon,
                  label: 'Histori Pelanggan',
                  onTap: () => nav.openOrder(OrderTab.history),
                ),
                OrderTab.reservation => _HeaderButton(
                  icon: AppAsset.scanIcon,
                  label: 'Scan Barcode',
                  onTap: () => openScanBooking(context),
                ),
                OrderTab.history => const SizedBox.shrink(),
              },
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

// Tombol emas muda di header ("Histori Pelanggan", "Scan Barcode")
class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColor.goldSoft,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: AppIcon(icon, size: 16),
      label: Text(label),
    );
  }
}
