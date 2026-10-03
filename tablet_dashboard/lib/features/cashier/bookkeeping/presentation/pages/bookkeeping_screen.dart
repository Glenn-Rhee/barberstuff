import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/widgets/history_tab.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/widgets/session_tab.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_tabs.dart';

// Halaman Pembukuan: sesi kasir yang sedang buka + history shift harian
class BookkeepingScreen extends StatefulWidget {
  const BookkeepingScreen({super.key});

  @override
  State<BookkeepingScreen> createState() => _BookkeepingScreenState();
}

class _BookkeepingScreenState extends State<BookkeepingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            title: 'Pembukuan',
            subtitle:
                'Catat kas masuk dan keluar, lalu cocokkan saat tutup shift.',
            actions: [StoreSelector(), StoreOpenChip()],
          ),
          const SizedBox(height: 12),
          PageTabs(
            tabs: const ['Sesi Kasir', 'History Harian'],
            icons: const [Icons.point_of_sale_outlined, Icons.history],
            selected: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: 16),
          Expanded(child: _tab == 0 ? const SessionTab() : const HistoryTab()),
        ],
      ),
    );
  }
}
