import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/customer/data/customer_api.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_kpi.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';

// Filter status pelanggan
enum CustomerFilter {
  all('Semua Status'),
  member('Member'),
  regular('Reguler');

  const CustomerFilter(this.label);

  final String label;
}

// Urutan daftar pelanggan
enum CustomerSort {
  newest('Terbaru'),
  name('Nama A-Z'),
  visits('Kunjungan terbanyak'),
  lastVisit('Terakhir datang');

  const CustomerSort(this.label);

  final String label;
}

// Semua pelanggan dimuat (maks [_maxPages] x 50), disaring di tablet
class CustomerHistoryController extends ChangeNotifier {
  CustomerHistoryController(this._api);

  static const pageSize = 8;
  static const _apiLimit = 50;
  static const _maxPages = 20;

  final CustomerApi _api;

  List<CustomerProfile> all = const [];
  CustomerKpi kpi = const CustomerKpi();

  // true = pelanggan lebih banyak dari batas muat
  bool truncated = false;

  String query = '';
  CustomerFilter filter = CustomerFilter.all;
  CustomerSort sort = CustomerSort.newest;
  int page = 1;
  String? selectedId;

  bool loading = false;
  String? error;

  // Hasil cari + filter + urut, semua halaman
  List<CustomerProfile> get filtered {
    final keyword = query.trim().toLowerCase();
    final digits = digitsOf(query);
    final list = [
      for (final c in all)
        if (_matchFilter(c) &&
            (keyword.isEmpty ||
                c.name.toLowerCase().contains(keyword) ||
                c.code.toLowerCase().contains(keyword) ||
                (digits.length >= 3 &&
                    digitsOf(c.phone ?? '').contains(digits))))
          c,
    ];
    switch (sort) {
      case CustomerSort.newest:
        break; // urutan dari server sudah terbaru
      case CustomerSort.name:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case CustomerSort.visits:
        list.sort((a, b) => b.totalVisited.compareTo(a.totalVisited));
      case CustomerSort.lastVisit:
        list.sort(
          (a, b) => (b.lastVisitedAt ?? DateTime(0)).compareTo(
            a.lastVisitedAt ?? DateTime(0),
          ),
        );
    }
    return list;
  }

  int get totalPages {
    final count = filtered.length;
    return count == 0 ? 1 : (count / pageSize).ceil();
  }

  // Isi halaman yang sedang dibuka
  List<CustomerProfile> get customers =>
      filtered.skip((page - 1) * pageSize).take(pageSize).toList();

  // Pelanggan pakai aplikasi yang sudah dimuat
  int get memberCount => all.where((c) => c.isMember).length;

  CustomerProfile? get selected =>
      all.where((c) => c.id == selectedId).firstOrNull;

  bool _matchFilter(CustomerProfile c) => switch (filter) {
    CustomerFilter.all => true,
    CustomerFilter.member => c.isMember,
    CustomerFilter.regular => !c.isMember,
  };

  // [silent] = muat ulang diam-diam, kalau gagal data lama tetap
  Future<void> refresh({bool silent = false}) async {
    if (silent && loading) return;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final items = <CustomerProfile>[];
      var more = false;
      for (var p = 1; p <= _maxPages; p++) {
        final result = await _api.customers(page: p, limit: _apiLimit);
        if (p == 1) kpi = result.kpi;
        items.addAll(result.items);
        more = result.items.length == _apiLimit;
        if (!more) break;
      }
      all = items;
      truncated = more;
      page = page.clamp(1, totalPages);
      error = null;
      if (selected == null) selectedId = null;
    } on ApiException catch (e) {
      if (silent) return;
      error = e.message;
      all = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    query = value;
    page = 1;
    notifyListeners();
  }

  void setFilter(CustomerFilter value) {
    filter = value;
    page = 1;
    notifyListeners();
  }

  void setSort(CustomerSort value) {
    sort = value;
    page = 1;
    notifyListeners();
  }

  void setPage(int value) {
    page = value.clamp(1, totalPages);
    notifyListeners();
  }

  void select(CustomerProfile customer) {
    selectedId = customer.id;
    notifyListeners();
  }

  // Pelanggan dengan no HP persis sama, null = belum pernah datang
  Future<CustomerProfile?> findByPhone(String phone) async {
    final digits = digitsOf(phone);
    if (digits.length < 9) return null;
    try {
      final result = await _api.customers(query: phone.trim(), limit: 5);
      return result.items
          .where((c) => digitsOf(c.phone ?? '') == digits)
          .firstOrNull;
    } on ApiException {
      return null;
    }
  }

  static String digitsOf(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');
}
