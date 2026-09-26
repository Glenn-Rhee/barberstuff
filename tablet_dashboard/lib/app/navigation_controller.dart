import 'package:flutter/foundation.dart';

enum AppSection { dashboard, kasir, pelanggan, pembukuan, konfigurasi }

enum KasirTab { langsung, reservasi }

class NavigationController extends ChangeNotifier {
  AppSection section = AppSection.dashboard;
  KasirTab kasirTab = KasirTab.langsung;

  /// Collapsed sidebar shows icons only, leaving more room for the content.
  bool sidebarExpanded = true;

  void toggleSidebar() {
    sidebarExpanded = !sidebarExpanded;
    notifyListeners();
  }

  void go(AppSection value) {
    section = value;
    notifyListeners();
  }

  void openKasir(KasirTab tab) {
    section = AppSection.kasir;
    kasirTab = tab;
    notifyListeners();
  }
}
