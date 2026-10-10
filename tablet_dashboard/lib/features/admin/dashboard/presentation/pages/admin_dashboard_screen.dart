import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:tablet_dashboard/features/auth/presentation/widgets/staff_profile_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/capster_list_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/shift_card.dart';

// Dashboard admin: ringkasan toko + akses fitur kasir.
// Kartu khusus admin ditambah di [side]
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Dashboard Admin',
      side: [StaffProfileCard(), ShiftCard(), CapsterListCard()],
    );
=======

class AdminDashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Material();
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  }
}
