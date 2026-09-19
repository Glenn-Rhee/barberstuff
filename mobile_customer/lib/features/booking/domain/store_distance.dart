import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';

double? storeDistanceKm(StoreSummary store, UserPosition? from) {
  final StoreCoordinate? at = store.coordinate;
  if (from == null || at == null) return null;

  return LocationService.distanceKm(
    from: from,
    latitude: at.latitude,
    longitude: at.longitude,
  );
}

/// Cabang terdekat lebih dulu; yang tanpa koordinat jatuh ke belakang.
List<StoreSummary> sortStoresByDistance(
  List<StoreSummary> stores,
  UserPosition? from,
) {
  if (from == null) return stores;

  final List<StoreSummary> sorted = List<StoreSummary>.of(stores);
  sorted.sort((StoreSummary a, StoreSummary b) {
    final double da = storeDistanceKm(a, from) ?? double.infinity;
    final double db = storeDistanceKm(b, from) ?? double.infinity;
    return da.compareTo(db);
  });

  return List<StoreSummary>.unmodifiable(sorted);
}
