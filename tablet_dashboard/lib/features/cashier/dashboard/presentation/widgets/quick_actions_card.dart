import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/shell/navigation_controller.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/scan_qr_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/cash_out_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tombol pintas: scan QR, catat kas keluar, buka kasir
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final open = context.select<ShiftController, bool>((s) => s.isOpen);
    final style = OutlinedButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AKSI CEPAT', style: AppTextStyle.bodyBold),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: () => scanQrAndCheckIn(context),
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Scan QR Booking'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: open ? () => showCashOutDialog(context) : null,
                  icon: const Icon(Icons.trending_down, size: 20),
                  label: const Text('Catat Kas Keluar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: () => context
                      .read<NavigationController>()
                      .openOrder(OrderTab.walkIn),
                  icon: const Icon(Icons.point_of_sale_outlined, size: 20),
                  label: const Text('Buka Kasir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
