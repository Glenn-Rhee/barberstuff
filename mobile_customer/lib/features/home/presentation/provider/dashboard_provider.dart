import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';

/// Isi dashboard: cabang dan booking milik akun ini, semuanya dari server.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._getStores, this._history, this._location) {
    _history.addListener(notifyListeners);
    load();
  }

  static const int nearbyLimit = 6;
  static const int historyLimit = 3;

  final GetStores _getStores;
  final CustomerBookingsProvider _history;
  final LocationService _location;

  List<StoreSummary> _stores = const <StoreSummary>[];
  UserPosition? _position;
  bool _loadingStores = false;
  ApiException? _storesError;

  List<StoreSummary> get stores => _stores.take(nearbyLimit).toList();
  bool get loadingStores => _loadingStores;
  ApiException? get storesError => _storesError;

  double? distanceOf(StoreSummary store) => storeDistanceKm(store, _position);

  /// Cabang paling dekat. null kalau posisi pengguna belum diketahui,
  /// supaya tidak ada cabang yang diklaim terdekat padahal cuma urutan acak.
  StoreSummary? get nearest {
    if (_position == null || _stores.isEmpty) return null;
    return _stores.first;
  }

  BookingRecord? get upcoming => _history.upcoming;

  List<BookingRecord> get history =>
      _history.completed.take(historyLimit).toList(growable: false);

  /// Dipanggil setelah pengguna menjawab dialog izin lokasi.
  /// load() kadang sudah jalan duluan waktu izin belum ada, jadi posisinya
  /// perlu diambil ulang supaya jarak cabang muncul tanpa buka tutup aplikasi.
  Future<void> refreshLocation() async {
    final UserPosition? fresh = await _location.current();
    if (fresh == null) return;

    _position = fresh;
    _stores = sortStoresByDistance(_stores, _position);
    notifyListeners();
  }

  Future<void> load() async {
    await Future.wait(<Future<void>>[_loadStores(), _loadBookings()]);
  }

  Future<void> _loadBookings() async {
    try {
      await _history.refresh();
    } on ApiException {
      // Beranda tetap tampil tanpa kartu booking. Halaman riwayat yang
      // menampilkan pesan gagalnya.
    }
  }

  Future<void> _loadStores() async {
    _loadingStores = true;
    _storesError = null;
    notifyListeners();

    try {
      final CachedResult<List<StoreSummary>> result = await _getStores(
        const GetStoresParams(),
      );
      _position ??= _location.lastKnown;
      _stores = sortStoresByDistance(result.data, _position);
    } on ApiException catch (e) {
      _storesError = e;
    } finally {
      _loadingStores = false;
      notifyListeners();
    }

    final UserPosition? fresh = await _location.current();
    if (fresh == null) return;

    _position = fresh;
    _stores = sortStoresByDistance(_stores, _position);
    notifyListeners();
  }

  @override
  void dispose() {
    _history.removeListener(notifyListeners);
    super.dispose();
  }
}
