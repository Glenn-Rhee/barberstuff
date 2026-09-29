import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';

class StoreReview {
  const StoreReview({
    required this.id,
    required this.message,
    required this.rating,
    required this.userName,
    required this.userImageUrl,
    required this.userTier,
  });

  final String id;
  final String message;
  final int rating;
  final String userName;
  final String userImageUrl;
  final String userTier;
}

class CapsterItem {
  const CapsterItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.avgRating,
    required this.status,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double avgRating;
  final String status;

  bool get isActive => status.toLowerCase().trim() == 'active';
}

class StoreDetail {
  const StoreDetail({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.bannerUrl,
    required this.description,
    required this.storeType,
    required this.status,
    required this.avgRating,
    required this.totalService,
    required this.totalCapster,
    required this.totalPackage,
    required this.reviews,
    this.coordinate,
    this.openHour,
    this.closeHour,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String bannerUrl;
  final String description;
  final String storeType;
  final String status;
  final double avgRating;
  final int totalService;
  final int totalCapster;
  final int totalPackage;
  final List<StoreReview> reviews;
  final StoreCoordinate? coordinate;

  /// Jam dinding toko, bukan titik waktu: 10:00 berarti 10:00 di cabang.
  final DateTime? openHour;
  final DateTime? closeHour;

  bool get isOpen => status.toLowerCase().trim() == 'open';
  bool get isLite => storeType.toLowerCase().trim() == 'lite';
  int get reviewCount => reviews.length;

  /// Bentuk ringkas yang dipakai alur booking, supaya booking dari detail
  /// cabang bisa langsung mulai tanpa memilih cabang lagi.
  StoreSummary toSummary() => StoreSummary(
    id: id,
    name: name,
    address: address,
    phoneNumber: phoneNumber,
    bannerUrl: bannerUrl,
    storeType: storeType,
    status: status,
    avgRating: avgRating,
    totalCapster: totalCapster,
    totalService: totalService,
    totalPackage: totalPackage,
    description: description,
    coordinate: coordinate,
  );
}
