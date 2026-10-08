import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/admin/branch_list/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/pages/employee_list_screen.dart';
import 'package:tablet_dashboard/features/admin/employee_list/presentation/provider/employee_list_controller.dart';

// Menu Manajemen Karyawan (admin), navigator sendiri supaya sidebar tetap.
// Daftar karyawan dipakai bersama halaman daftar dan Tambah Karyawan
class EmployeeSection extends StatefulWidget {
  const EmployeeSection({super.key});

  @override
  State<EmployeeSection> createState() => _EmployeeSectionState();
}

class _EmployeeSectionState extends State<EmployeeSection> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          EmployeeListController(context.read<BranchApi>())..refresh(),
      // Tombol back Android menutup halaman karyawan dulu, bukan aplikasinya
      child: NavigatorPopHandler<Object?>(
        onPopWithResult: (_) => _navigator.currentState?.maybePop(),
        child: Navigator(
          key: _navigator,
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
        ),
      ),
    );
  }
}
