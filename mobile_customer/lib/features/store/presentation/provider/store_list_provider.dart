import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';

/// Daftar seluruh cabang, diurut dari yang terdekat dan bisa dicari.
/// Beda dengan DashboardProvider yang cuma ambil 6 teratas.
class StoreListProvider extends ChangeNotifier {
  StoreListProvider(this._getStores, this._location) {
    searchController.addListener(_onSearchChanged);
    load();
  }

  final GetStores _getStores;
  final LocationService _location;

  final TextEditingController searchController = TextEditingController();

  List<StoreSummary> _all = const <StoreSummary>[];
  UserPosition? _position;
  String _query = '';
  bool _isLoading = false;
  ApiException? _error;

  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  List<StoreSummary> get stores {
    final String needle = _query.toLowerCase();
    if (needle.isEmpty) return _all;

    return _all
        .where(
          (StoreSummary store) =>
              store.name.toLowerCase().contains(needle) ||
              store.address.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  double? distanceOf(StoreSummary store) => storeDistanceKm(store, _position);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final CachedResult<List<StoreSummary>> result = await _getStores(
        const GetStoresParams(),
      );
      _position ??= _location.lastKnown;
      _all = sortStoresByDistance(result.data, _position);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Lokasi terbaru datang belakangan, urutannya disegarkan lagi.
    final UserPosition? fresh = await _location.current();
    if (fresh == null) return;

    _position = fresh;
    _all = sortStoresByDistance(_all, _position);
    notifyListeners();
  }

  void _onSearchChanged() {
    final String next = searchController.text.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
