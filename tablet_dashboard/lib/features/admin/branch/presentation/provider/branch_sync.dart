import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';

// Data menu lain yang ikut berubah saat admin mengubah cabang
class BranchSync {
  const BranchSync._();

  // Pilihan cabang di header (nama, jam, status buka). Kalau cabang yang
  // sedang dipakai dihapus, data yang ikut toko dimuat ulang ke cabang baru
  static Future<void> stores(BuildContext context) async {
    final profile = context.read<SessionController>().profile;
    if (profile == null) return;
    final store = context.read<StoreController>();
    final catalog = context.read<CatalogController>();
    final attendance = context.read<AttendanceController>();
    final dashboard = context.read<DashboardController>();
    final before = store.storeId;
    await store.load(profile);
    if (store.storeId == before) return;
    catalog.load(store.storeId);
    attendance.load(store.storeId);
    dashboard.refresh();
  }

  // Layanan & capster di Kasir, kalau cabangnya sedang dipakai
  static void catalog(BuildContext context, String storeId) {
    final catalog = context.read<CatalogController>();
    if (catalog.storeId != storeId) return;
    catalog.refresh(silent: true);
    catalog.loadCapsters(silent: true);
  }
}
