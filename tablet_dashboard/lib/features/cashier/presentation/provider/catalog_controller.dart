import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../data/api/barberstuff_api.dart';
import '../../../../shared/models/person.dart';
import '../../../../shared/models/service_item.dart';

/// Services, packages and capsters of the store, straight from the API.
/// Search and paging happen server side (`GET /service`).
class CatalogController extends ChangeNotifier {
  CatalogController(this._api);

  static const pageSize = 8;

  final BarberstuffApi _api;

  String storeId = '';
  ServiceType type = ServiceType.service;
  String query = '';
  int page = 1;
  int totalPages = 1;
  int totalData = 0;

  List<ServiceItem> services = const [];
  List<Capster> capsters = const [];

  bool loading = false;
  bool loadingCapsters = false;
  String? error;
  String? capsterError;

  Timer? _debounce;

  List<Capster> get activeCapsters => [
    for (final capster in capsters)
      if (capster.active) capster,
  ];

  Future<void> load(String storeId) async {
    this.storeId = storeId;
    await Future.wait([refresh(), loadCapsters()]);
  }

  Future<void> refresh() async {
    if (storeId.isEmpty) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _api.services(
        storeId: storeId,
        type: type,
        name: query.trim().isEmpty ? null : query.trim(),
        page: page,
        limit: pageSize,
      );
      services = result.items;
      totalPages = result.totalPages == 0 ? 1 : result.totalPages;
      totalData = result.totalData;
    } on ApiException catch (e) {
      error = e.message;
      services = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCapsters() async {
    if (storeId.isEmpty) return;
    loadingCapsters = true;
    capsterError = null;
    notifyListeners();
    try {
      capsters = await _api.capsters(storeId);
    } on ApiException catch (e) {
      capsterError = e.message;
      capsters = const [];
    } finally {
      loadingCapsters = false;
      notifyListeners();
    }
  }

  void setType(ServiceType value) {
    if (type == value) return;
    type = value;
    page = 1;
    refresh();
  }

  /// Typing hits the API once the cashier pauses.
  void setQuery(String value) {
    query = value;
    page = 1;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), refresh);
    notifyListeners();
  }

  void setPage(int value) {
    page = value.clamp(1, totalPages);
    refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
