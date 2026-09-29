import 'package:mobile_barberstuff/core/utils/json_value.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';

class StoreCoordinateModel extends StoreCoordinate {
  const StoreCoordinateModel({
    required super.latitude,
    required super.longitude,
  });

  /// Backend menyimpan koordinat sebagai teks "lat,lng", kadang terbalik.
  /// Garis lintang tidak pernah lebih dari 90, jadi urutannya bisa ditebak.
  static StoreCoordinateModel? fromJson(Object? raw) {
    if (raw is! String || !raw.contains(',')) return null;

    final List<String> parts = raw.split(',');
    if (parts.length != 2) return null;

    final double? a = double.tryParse(parts[0].trim());
    final double? b = double.tryParse(parts[1].trim());
    if (a == null || b == null) return null;

    final bool firstLooksLikeLatitude = a.abs() <= 90 && b.abs() > 90;
    return firstLooksLikeLatitude
        ? StoreCoordinateModel(latitude: a, longitude: b)
        : StoreCoordinateModel(latitude: b, longitude: a);
  }

  static String? toJson(StoreCoordinate? value) =>
      value == null ? null : '${value.latitude},${value.longitude}';
}

class StoreSummaryModel extends StoreSummary {
  const StoreSummaryModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phoneNumber,
    required super.bannerUrl,
    required super.storeType,
    required super.status,
    required super.avgRating,
    required super.totalCapster,
    required super.totalService,
    required super.totalPackage,
    super.description,
    super.coordinate,
  });

  factory StoreSummaryModel.fromEntity(StoreSummary store) {
    return StoreSummaryModel(
      id: store.id,
      name: store.name,
      address: store.address,
      phoneNumber: store.phoneNumber,
      bannerUrl: store.bannerUrl,
      storeType: store.storeType,
      status: store.status,
      avgRating: store.avgRating,
      totalCapster: store.totalCapster,
      totalService: store.totalService,
      totalPackage: store.totalPackage,
      description: store.description,
      coordinate: store.coordinate,
    );
  }

  factory StoreSummaryModel.fromJson(Map<String, dynamic> json) {
    return StoreSummaryModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
      address: jsonText(json['address']),
      phoneNumber: jsonText(json['phone_number']),
      bannerUrl: jsonText(json['banner_url']),
      storeType: jsonText(json['store_type']),
      status: jsonText(json['status']),
      avgRating: jsonDouble(json['avg_rating']),
      totalCapster: jsonInt(json['total_capster']),
      totalService: jsonInt(json['total_service']),
      totalPackage: jsonInt(json['total_package']),
      description: json['description'] as String?,
      coordinate: StoreCoordinateModel.fromJson(json['coordinate']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'address': address,
    'phone_number': phoneNumber,
    'banner_url': bannerUrl,
    'store_type': storeType,
    'status': status,
    'avg_rating': avgRating,
    'total_capster': totalCapster,
    'total_service': totalService,
    'total_package': totalPackage,
    'description': description,
    'coordinate': StoreCoordinateModel.toJson(coordinate),
  };
}
