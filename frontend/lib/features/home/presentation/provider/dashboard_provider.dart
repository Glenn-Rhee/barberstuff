import 'package:flutter/foundation.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/store_distance.dart';

/// Isi dashboard: cabang dari server, booking dan riwayat dari jurnal lokal.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._repo, this._journal, this._location) {
    _journal.addListener(notifyListeners);
    load();
  }

  static const int nearbyLimit = 6;
  static const int historyLimit = 3;

  final BookingRepository _repo;
  final BookingJournal _journal;
  final LocationService _location;

  List<StoreSummary> _stores = const <StoreSummary>[];
  UserPosition? _position;
  bool _loadingStores = false;
  ApiException? _storesError;

  List<StoreSummary> get stores => _stores.take(nearbyLimit).toList();
  bool get loadingStores => _loadingStores;
  ApiException? get storesError => _storesError;

  double? distanceOf(StoreSummary store) => storeDistanceKm(store, _position);

  BookingRecord? get upcoming => _journal.upcoming;

  List<BookingRecord> get history =>
      _journal.past.take(historyLimit).toList(growable: false);

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
    _loadingStores = true;
    _storesError = null;
    notifyListeners();

    try {
      final CachedResult<List<StoreSummary>> result = await _repo.getStores();
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
    _journal.removeListener(notifyListeners);
    super.dispose();
  }
}
