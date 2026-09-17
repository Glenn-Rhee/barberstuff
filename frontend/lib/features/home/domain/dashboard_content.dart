import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';

class ActiveBooking {
  const ActiveBooking({
    required this.orderId,
    required this.storeName,
    required this.storeAddress,
    required this.capsterName,
    required this.schedule,
    this.capsterPhotoUrl,
  });

  final String orderId;
  final String storeName;
  final String storeAddress;
  final String capsterName;
  final DateTime schedule;
  final String? capsterPhotoUrl;

  /// 8 karakter pertama UUID dipakai sebagai nomor order yang enak dibaca.
  factory ActiveBooking.fromRecord(BookingRecord record) => ActiveBooking(
    orderId: record.id.length > 8 ? record.id.substring(0, 8) : record.id,
    storeName: record.storeName,
    storeAddress: record.storeAddress,
    capsterName: record.capsterName,
    schedule: record.scheduledAt,
  );
}

class NearbyStore {
  const NearbyStore({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.distanceKm,
    required this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String city;
  final double rating;
  final double distanceKm;
  final String imageAsset;
  final String? imageUrl;

  factory NearbyStore.fromSummary(StoreSummary store, {double? distanceKm}) {
    return NearbyStore(
      id: store.id,
      name: store.name,
      city: store.address,
      rating: store.avgRating,
      distanceKm: distanceKm ?? 0,
      imageAsset: AppAssets.storeDepok,
      imageUrl: store.bannerUrl.isEmpty ? null : store.bannerUrl,
    );
  }
}

class HaircutHistory {
  const HaircutHistory({
    required this.id,
    required this.serviceName,
    required this.capsterName,
    required this.date,
    required this.storeName,
    required this.price,
  });

  final String id;
  final String serviceName;
  final String capsterName;
  final DateTime date;
  final String storeName;
  final int price;

  factory HaircutHistory.fromRecord(BookingRecord record) => HaircutHistory(
    id: record.id,
    serviceName: record.serviceName,
    capsterName: record.capsterName,
    date: record.scheduledAt,
    storeName: record.storeName,
    price: record.grandTotal.round(),
  );
}

class BenefitItem {
  const BenefitItem({
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;
}
