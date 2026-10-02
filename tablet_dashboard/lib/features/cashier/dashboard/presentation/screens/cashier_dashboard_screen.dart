import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/capster_list_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/shift_card.dart';

// Dashboard kasir: fokus ke shift hari ini dan booking yang masuk
class CashierDashboardScreen extends StatelessWidget {
  const CashierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Dashboard Kasir',
      side: [ShiftCard(), CapsterListCard()],
    );
  }
}
