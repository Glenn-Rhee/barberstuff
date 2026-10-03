import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/pages/branch_list_screen.dart';

// Menu Mengelola Cabang (khusus admin). Punya navigator sendiri supaya
// detail / tambah / edit cabang terbuka di area konten, sidebar tetap tampil
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
