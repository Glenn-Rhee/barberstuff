import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/capster_list_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/shift_card.dart';
import 'package:tablet_dashboard/features/mitra/dashboard/presentation/widgets/staff_profile_card.dart';

// Dashboard mitra, kartu khusus mitra di [side]
class MitraDashboardScreen extends StatelessWidget {
  const MitraDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Dashboard Mitra',
      side: [StaffProfileCard(), ShiftCard(), CapsterListCard()],
    );
  }
}
