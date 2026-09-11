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
}

class NearbyStore {
  const NearbyStore({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.distanceKm,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String city;
  final double rating;
  final double distanceKm;
  final String imageAsset;
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
