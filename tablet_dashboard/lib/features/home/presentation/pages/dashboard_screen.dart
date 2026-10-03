import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/features/admin/dashboard/presentation/pages/admin_dashboard_screen.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/pages/bookkeeping_screen.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/presentation/pages/customers_screen.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/pages/cashier_dashboard_screen.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/pages/order_screen.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/settings/presentation/pages/settings_screen.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/features/home/presentation/widgets/app_sidebar.dart';
import 'package:tablet_dashboard/features/home/presentation/widgets/live_refresh.dart';
import 'package:tablet_dashboard/features/mitra/dashboard/presentation/pages/mitra_dashboard_screen.dart';

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

  // Ambil data toko sekali setelah login. Toko dimuat dulu,
  // karena katalog dan absensi ikut toko yang dipakai
  Future<void> _bootstrap() async {
    if (!mounted) return;
    final profile = context.read<SessionController>().profile;
    if (profile == null) return;
    final store = context.read<StoreController>();
    final catalog = context.read<CatalogController>();
    final attendance = context.read<AttendanceController>();
    final printer = context.read<PrinterController>();
    context.read<ShiftController>()
      ..setEnabled(profile.staffRole == StaffRole.cashier)
      ..refresh();
    context.read<BookingsController>().refresh();

    await store.load(profile);
    catalog.load(store.storeId);
    attendance.load(store.storeId);
    try {
      await printer.loadDevices();
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

    return LiveRefresh(
      child: Scaffold(
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
                AppSection.customers => const CustomersScreen(),
                AppSection.bookkeeping => const BookkeepingScreen(),
                AppSection.settings => const SettingsScreen(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
