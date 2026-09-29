import 'package:mobile_barberstuff/core/services/location_service.dart';

class StoreCoordinate {
  const StoreCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Cabang dalam daftar: cukup untuk kartu cabang dan memulai booking.
class StoreSummary {
  const StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.bannerUrl,
    required this.storeType,
    required this.status,
    required this.avgRating,
    required this.totalCapster,
    required this.totalService,
    required this.totalPackage,
    this.description,
    this.coordinate,
  });

  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String bannerUrl;
  final String storeType;
  final String status;
  final double avgRating;
  final int totalCapster;
  final int totalService;
  final int totalPackage;
  final String? description;
  final StoreCoordinate? coordinate;

  bool get isLite => storeType.toLowerCase().trim() == 'lite';
  bool get isOpen => status.toLowerCase().trim() == 'open';
}

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
