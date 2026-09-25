import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/printer/bluetooth_printer.dart';
import '../core/printer/printer_controller.dart';
import '../core/printer/receipt_logo.dart';
import '../features/auth/presentation/provider/session_controller.dart';
import '../features/cashier/presentation/pages/kasir_page.dart';
import '../features/cashier/presentation/provider/catalog_controller.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/provider/shift_controller.dart';
import '../features/reservation/presentation/provider/bookings_controller.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/widgets/app_sidebar.dart';
import '../shared/widgets/coming_soon_page.dart';
import 'navigation_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    ReceiptLogo.load(); // receipt header bitmap
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  /// Pulls the store's data once the cashier is signed in.
  Future<void> _bootstrap() async {
    if (!mounted) return;
    final storeId = context.read<SessionController>().storeId;
    context.read<CatalogController>().load(storeId);
    context.read<ShiftController>().refresh();
    context.read<BookingsController>().refresh();
    try {
      await context.read<PrinterController>().loadDevices();
    } on PrinterException {
      // Shown again in Konfigurasi and when printing; no need to nag on startup.
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = context.select<NavigationController, AppSection>((n) => n.section);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSidebar(),
          Expanded(
            child: switch (section) {
              AppSection.dashboard => const DashboardPage(),
              AppSection.kasir => const KasirPage(),
              AppSection.pelanggan => const ComingSoonPage(
                title: 'Pelanggan',
                subtitle: 'Data member dan riwayat kunjungan pelanggan.',
              ),
              AppSection.pembukuan => const ComingSoonPage(
                title: 'Pembukuan',
                subtitle: 'Laporan transaksi, kas masuk, dan kas keluar.',
              ),
              AppSection.konfigurasi => const SettingsPage(),
            },
          ),
        ],
      ),
    );
  }
}
