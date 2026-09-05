class BookingStore {
  const BookingStore({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    this.isLite = false,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final bool isLite;
}

class BookingCapster {
  const BookingCapster({
    required this.id,
    required this.name,
    required this.photoAsset,
    required this.rating,
  });

  final String id;
  final String name;
  final String photoAsset;
  final double rating;
}
