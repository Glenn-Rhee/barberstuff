import 'package:flutter/foundation.dart';

// Menu sidebar, sama untuk semua role (yang beda cuma isi Dashboard)
enum AppSection { dashboard, order, settings }

// Tampilan di halaman Kasir: dua tab + histori pelanggan
enum OrderTab { walkIn, reservation, history }

// Menu dan tab Kasir yang sedang dibuka, plus status sidebar
class NavigationController extends ChangeNotifier {
  AppSection section = AppSection.dashboard;
  OrderTab orderTab = OrderTab.walkIn;

  // Sidebar kecil = ikon saja, area konten jadi lebih lebar
  bool sidebarExpanded = true;

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
