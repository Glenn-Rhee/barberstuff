import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';

// Menu sidebar. Isi Dashboard beda tiap role, Mengelola Cabang &
// Manajemen Karyawan khusus admin
enum AppSection {
  dashboard,
  branches,
  employees,
  order,
  customers,
  bookkeeping,
  settings,
}

// Tampilan di halaman Kasir: dua tab + histori pelanggan
enum OrderTab { walkIn, reservation, history }

// Menu dan tab Kasir yang sedang dibuka, plus status sidebar
class NavigationController extends ChangeNotifier {
  AppSection section = AppSection.dashboard;
  OrderTab orderTab = OrderTab.walkIn;

  // Sidebar kecil = ikon saja, area konten jadi lebih lebar
  bool sidebarExpanded = true;

  // Menu yang dimiliki admin
  static const adminSections = {AppSection.branches, AppSection.employees};

  // Admin cuma punya menu admin, selain itu kembali ke Mengelola Cabang
  AppSection sectionFor(StaffRole? role) =>
      role != StaffRole.admin || adminSections.contains(section)
      ? section
      : AppSection.branches;

  void toggleSidebar() {
    sidebarExpanded = !sidebarExpanded;
    notifyListeners();
  }

  void go(AppSection value) {
    section = value;
    notifyListeners();
  }

  void openOrder(OrderTab tab) {
    section = AppSection.order;
    orderTab = tab;
    notifyListeners();
  }

  // Balik ke awal saat ganti akun
  void reset() {
    section = AppSection.dashboard;
    orderTab = OrderTab.walkIn;
    notifyListeners();
  }
}
