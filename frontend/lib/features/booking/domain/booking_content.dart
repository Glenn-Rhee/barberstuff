class BookingStore {
  const BookingStore({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.imageAsset,
    required this.rating,
    this.isNewbie = false,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String imageAsset;
  final double rating;
  final bool isNewbie;
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

enum ServiceKind { single, package }

class BookingService {
  const BookingService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.kind,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final ServiceKind kind;

  BookingService copyWith({String? name, String? description, int? price}) {
    return BookingService(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      kind: kind,
    );
  }
}

enum ReceiptCodeType { barcode, qr }
