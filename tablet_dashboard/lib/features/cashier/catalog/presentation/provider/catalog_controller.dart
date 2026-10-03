import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Filter katalog di halaman Kasir
enum CatalogFilter {
  all('Semua'),
  service('Service'),
  package('Paket');

  const CatalogFilter(this.label);

  final String label;

  bool accepts(ServiceItem item) => switch (this) {
    all => true,
    service => item.type == ServiceType.service,
    package => item.type == ServiceType.package,
  };
}

// Layanan, paket, dan capster toko. Semua layanan dimuat sekali
// (GET /service wajib pilih type, jadi service & paket diambil terpisah),
// lalu filter, cari, dan halaman diproses di tablet
class CatalogController extends ChangeNotifier {
  CatalogController(this._api);

  static const pageSize = 8;

  // Batas limit backend, maks 4 halaman per type
  static const _apiLimit = 50;
  static const _maxPages = 4;

  final CatalogApi _api;

  String storeId = '';
  List<ServiceItem> all = const [];
  CatalogFilter filter = CatalogFilter.all;
  String query = '';
  int page = 1;

  List<Capster> capsters = const [];

  bool loading = false;
  bool loadingCapsters = false;
  String? error;
  String? capsterError;

  List<Capster> get activeCapsters => [
    for (final capster in capsters)
      if (capster.active) capster,
  ];

  // Hasil filter + cari, semua halaman
  List<ServiceItem> get filtered {
    final keyword = query.trim().toLowerCase();
    return [
      for (final item in all)
        if (filter.accepts(item) &&
            (keyword.isEmpty || item.name.toLowerCase().contains(keyword)))
          item,
    ];
  }

  int get totalPages {
    final count = filtered.length;
    return count == 0 ? 1 : (count / pageSize).ceil();
  }

  // Isi halaman yang sedang dibuka
  List<ServiceItem> get services =>
      filtered.skip((page - 1) * pageSize).take(pageSize).toList();

  ServiceItem? byId(String id) => all.where((s) => s.id == id).firstOrNull;

  Future<void> load(String storeId) async {
    this.storeId = storeId;
    page = 1;
    await Future.wait([refresh(), loadCapsters()]);
  }

  // [silent] = muat ulang di belakang layar: data lama tetap tampil tanpa
  // kerangka loading, dan kalau gagal data lama tidak dihapus
  Future<void> refresh({bool silent = false}) async {
    if (storeId.isEmpty || (silent && loading)) return;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        for (final type in ServiceType.values) _loadType(type),
      ]);
      all = [for (final items in results) ...items];
      page = page.clamp(1, totalPages);
      error = null;
    } on ApiException catch (e) {
      if (silent) return;
      error = e.message;
      all = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<ServiceItem>> _loadType(ServiceType type) async {
    final items = <ServiceItem>[];
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _api.services(
        storeId: storeId,
        type: type,
        page: page,
        limit: _apiLimit,
      );
      items.addAll(result.items);
      if (result.items.length < _apiLimit) break;
    }
    return items;
  }

  Future<void> loadCapsters({bool silent = false}) async {
    if (storeId.isEmpty || (silent && loadingCapsters)) return;
    if (!silent) {
      loadingCapsters = true;
      capsterError = null;
      notifyListeners();
    }
    try {
      capsters = await _api.capsters(storeId);
      capsterError = null;
    } on ApiException catch (e) {
      if (silent) return;
      capsterError = e.message;
      capsters = const [];
    } finally {
      loadingCapsters = false;
      notifyListeners();
    }
  }

  void setFilter(CatalogFilter value) {
    filter = value;
    page = 1;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    page = 1;
    notifyListeners();
  }

  void setPage(int value) {
    page = value.clamp(1, totalPages);
    notifyListeners();
  }
}
