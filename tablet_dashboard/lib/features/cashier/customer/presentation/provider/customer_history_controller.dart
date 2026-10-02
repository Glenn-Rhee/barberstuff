import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/customer/data/customer_api.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';

// Daftar histori pelanggan + cari pelanggan lama dari nomor telepon
class CustomerHistoryController extends ChangeNotifier {
  CustomerHistoryController(this._api);

  static const pageSize = 12;

  final CustomerApi _api;

  String query = '';
  int page = 1;
  int totalPages = 1;
  List<CustomerProfile> customers = const [];
  bool loading = false;
  String? error;

  Timer? _debounce;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _api.customers(
        query: query.trim().isEmpty ? null : query.trim(),
        page: page,
        limit: pageSize,
      );
      customers = result.items;
      totalPages = result.totalPages;
    } on ApiException catch (e) {
      error = e.message;
      customers = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Request ke API setelah kasir berhenti mengetik
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

  // Pelanggan yang no HP-nya sama persis, null kalau belum pernah datang
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
