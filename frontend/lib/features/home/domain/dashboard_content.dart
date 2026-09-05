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
    required this.rating,
    required this.distanceKm,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final double rating;
  final double distanceKm;
  final String imageAsset;
}

class HaircutHistory {
  const HaircutHistory({
    required this.id,
    required this.capsterName,
    required this.date,
    required this.storeName,
    required this.price,
  });

  final String id;
  final String capsterName;
  final DateTime date;
  final String storeName;
  final int price;
}
