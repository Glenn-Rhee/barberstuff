import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/store/data/store_api.dart';
import 'package:tablet_dashboard/features/cashier/store/domain/entities/store_info.dart';

// Toko yang dipakai. Kasir & mitra ikut akun, admin bisa ganti
class StoreController extends ChangeNotifier {
  StoreController(this._api);

  final StoreApi _api;

  StoreInfo? current;
  List<StoreInfo> options = const [];
  bool canSwitch = false;
  bool loading = false;
  String? error;

  String get storeId => current?.id ?? '';

  Future<void> load(StaffProfile profile) async {
    loading = true;
    error = null;
    canSwitch = profile.staffRole == StaffRole.admin;
    notifyListeners();
    try {
      current = switch (profile.staffRole) {
        StaffRole.admin => await _adminStore(),
        StaffRole.mitra => await _api.store(profile.storeId),
        _ => await _cashierStore(profile.storeId),
      };
    } on ApiException catch (e) {
      error = e.message;
      current ??= canSwitch ? null : StoreInfo(id: profile.storeId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<StoreInfo?> _adminStore() async {
    options = await _api.stores();
    return options.where((s) => s.id == current?.id).firstOrNull ??
        options.firstOrNull;
  }

  // Kasir: dari riwayat kas & slot booking, boleh gagal (id dari akun)
  Future<StoreInfo> _cashierStore(String storeId) async {
    var store = StoreInfo(id: storeId);
    try {
      final fromHistory = await _api.storeFromCashHistory();
      if (fromHistory != null) {
        store = store.copyWith(
          name: fromHistory.name,
          openHour: fromHistory.openHour,
          closeHour: fromHistory.closeHour,
        );
      }
    } on ApiException {
      // Belum ada riwayat kas, lanjut ke slot booking
    }
    if (store.hours == null) {
      try {
        final hours = await _api.hoursFromSlots(storeId, DateTime.now());
        if (hours != null) {
          store = store.copyWith(openHour: hours.open, closeHour: hours.close);
        }
      } on ApiException {
        // Jam toko tidak ketemu, dashboard tampil tanpa jam
      }
    }
    return store;
  }

  // Khusus admin
  void select(StoreInfo store) {
    if (!canSwitch) return;
    current = store;
    notifyListeners();
  }

  void clear() {
    current = null;
    options = const [];
    canSwitch = false;
    error = null;
    notifyListeners();
  }
}
