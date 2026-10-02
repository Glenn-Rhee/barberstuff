import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/shell/navigation_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';

// Pilihan "Pesanan Langsung" / "Dari Reservasi" di atas halaman Kasir
class OrderTabs extends StatelessWidget {
  const OrderTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Row(
      children: [
        Pill(
          label: 'Pesanan Langsung',
          selected: nav.orderTab == OrderTab.walkIn,
          onTap: () => nav.openOrder(OrderTab.walkIn),
        ),
        const SizedBox(width: 8),
        Pill(
          label: 'Dari Reservasi',
          selected: nav.orderTab == OrderTab.reservation,
          onTap: () => nav.openOrder(OrderTab.reservation),
        ),
      ],
    );
  }
}
