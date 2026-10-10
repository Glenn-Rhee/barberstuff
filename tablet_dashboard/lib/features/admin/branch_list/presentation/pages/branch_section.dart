import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/admin/branch_list/presentation/pages/branch_list_screen.dart';

// Menu Mengelola Cabang (admin), navigator sendiri supaya sidebar tetap
class BranchSection extends StatefulWidget {
  const BranchSection({super.key});

  @override
  State<BranchSection> createState() => _BranchSectionState();
}

class _BranchSectionState extends State<BranchSection> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Tombol back Android menutup halaman cabang dulu, bukan aplikasinya
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigator.currentState?.maybePop(),
      child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const BranchListScreen()),
      ),
    );
  }
}
