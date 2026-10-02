import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/shell/navigation_controller.dart';
import 'package:tablet_dashboard/app/shell/widgets/app_sidebar.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/screens/cashier_dashboard_screen.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/screens/order_screen.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/settings/presentation/screens/settings_screen.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/mitra/dashboard/presentation/screens/mitra_dashboard_screen.dart';

// Layar utama setelah login: sidebar di kiri, isi menu di kanan.
// Menu Dashboard beda tiap role, Kasir dan Konfigurasi sama
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    ReceiptLogo.load(); // logo kepala struk
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  // Ambil data toko sekali setelah login
  Future<void> _bootstrap() async {
    if (!mounted) return;
    final storeId = context.read<SessionController>().storeId;
    context.read<CatalogController>().load(storeId);
    context.read<ShiftController>().refresh();
    context.read<BookingsController>().refresh();
    try {
      await context.read<PrinterController>().loadDevices();
    } on PrinterException {
      // Error printer tampil lagi di Konfigurasi dan saat cetak
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = context.select<NavigationController, AppSection>(
      (n) => n.section,
    );
    final role = context.select<SessionController, StaffRole?>(
      (s) => s.staffRole,
    );

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSidebar(),
          Expanded(
            child: switch (section) {
              AppSection.dashboard => switch (role) {
                StaffRole.admin => const AdminDashboardScreen(),
                StaffRole.mitra => const MitraDashboardScreen(),
                _ => const CashierDashboardScreen(),
              },
              AppSection.order => const OrderScreen(),
              AppSection.settings => const SettingsScreen(),
            },
          ),
        ],
      ),
    );
  }
}
