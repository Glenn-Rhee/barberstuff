import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/shell/navigation_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/walk_in_view.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/bookings_view.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/scan_qr_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_status_chip.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';

// Halaman Kasir: tab Pesanan Langsung dan Dari Reservasi
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = context.select<NavigationController, OrderTab>(
      (n) => n.orderTab,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Kasir',
            subtitle: 'Layanan dan booking toko Anda.',
            actions: [
              OutlinedButton.icon(
                onPressed: () => scanQrAndCheckIn(context),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Scan QR'),
              ),
              const ShiftStatusChip(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: switch (tab) {
              OrderTab.walkIn => const WalkInView(),
              OrderTab.reservation => const BookingsView(),
            },
          ),
        ],
      ),
    );
  }
}
