import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';

// History Harian pembukuan: shift yang sudah ditutup per bulan
class CashHistoryController extends ChangeNotifier {
  CashHistoryController(this._api);

  static const pageSize = 10;

  // Batas limit backend, maks 4 halaman untuk ekspor sebulan
  static const _apiLimit = 50;
  static const _maxPages = 4;

  final CashSessionApi _api;

  String storeId = '';
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  String query = '';
  int page = 1;
  int totalPages = 1;
  List<CashHistoryEntry> entries = const [];
  String? selectedId;
  bool loading = false;
  String? error;

  Timer? _debounce;

  // Balasan request lama diabaikan (ganti bulan / cari berturut-turut)
  int _request = 0;

  CashHistoryEntry? get selected =>
      entries.where((e) => e.id == selectedId).firstOrNull;

  // 12 bulan terakhir untuk pilihan filter
  List<DateTime> get months {
    final now = DateTime.now();
    return [for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i)];
  }

  Future<void> load(String storeId) {
    this.storeId = storeId;
    page = 1;
    return refresh();
  }

  Future<void> refresh({bool silent = false}) async {
    final request = ++_request;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final result = await _api.history(
        month: month,
        query: query.trim().isEmpty ? null : query.trim(),
        storeId: storeId.isEmpty ? null : storeId,
        page: page,
        limit: pageSize,
      );
      if (request != _request) return;
      entries = result.items;
      totalPages = result.totalPages;
      error = null;
      if (selected == null) selectedId = entries.firstOrNull?.id;
    } on ApiException catch (e) {
      if (request != _request || silent) return;
      error = e.message;
      entries = const [];
    } finally {
      if (request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  // Semua shift di bulan terpilih, untuk ekspor laporan
  Future<List<CashHistoryEntry>> allForMonth() async {
    final all = <CashHistoryEntry>[];
    for (var p = 1; p <= _maxPages; p++) {
      final result = await _api.history(
        month: month,
        query: query.trim().isEmpty ? null : query.trim(),
        storeId: storeId.isEmpty ? null : storeId,
        page: p,
        limit: _apiLimit,
      );
      all.addAll(result.items);
      if (result.items.length < _apiLimit) break;
    }
    return all;
  }

  void setMonth(DateTime value) {
    month = value;
    page = 1;
    selectedId = null;
    refresh();
  }

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

  void select(CashHistoryEntry? entry) {
    selectedId = entry?.id;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
