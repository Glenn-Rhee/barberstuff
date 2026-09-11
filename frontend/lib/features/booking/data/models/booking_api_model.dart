enum ProductType {
  service,
  package;

  static ProductType fromJson(String? value) {
    return value?.toLowerCase().trim() == 'package'
        ? ProductType.package
        : ProductType.service;
  }
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

int _toInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}

String _toText(Object? value) => value is String ? value : '';

class StoreCoordinate {
  const StoreCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static StoreCoordinate? parse(Object? raw) {
    if (raw is! String || !raw.contains(',')) return null;

    final List<String> parts = raw.split(',');
    if (parts.length != 2) return null;

    final double? a = double.tryParse(parts[0].trim());
    final double? b = double.tryParse(parts[1].trim());
    if (a == null || b == null) return null;

    final bool firstLooksLikeLatitude = a.abs() <= 90 && b.abs() > 90;
    return firstLooksLikeLatitude
        ? StoreCoordinate(latitude: a, longitude: b)
        : StoreCoordinate(latitude: b, longitude: a);
  }
}

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
    'coordinate': coordinate == null
        ? null
        : '${coordinate!.latitude},${coordinate!.longitude}',
  };

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: _toText(json['id']),
      name: _toText(json['name']),
      address: _toText(json['address']),
      phoneNumber: _toText(json['phone_number']),
      bannerUrl: _toText(json['banner_url']),
      storeType: _toText(json['store_type']),
      status: _toText(json['status']),
      avgRating: _toDouble(json['avg_rating']),
      totalCapster: _toInt(json['total_capster']),
      totalService: _toInt(json['total_service']),
      totalPackage: _toInt(json['total_package']),
      description: json['description'] as String?,
      coordinate: StoreCoordinate.parse(json['coordinate']),
    );
  }
}

class SlotCapster {
  const SlotCapster({
    required this.id,
    required this.name,
    required this.avgRating,
    required this.imageUrl,
    required this.available,
  });

  final String id;
  final String name;
  final double avgRating;
  final String imageUrl;
  final bool available;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'avg_rating': avgRating,
    'image_url': imageUrl,
    'available': available,
  };

  factory SlotCapster.fromJson(Map<String, dynamic> json) {
    return SlotCapster(
      id: _toText(json['id']),
      name: _toText(json['name']),
      avgRating: _toDouble(json['avg_rating']),
      imageUrl: _toText(json['image_url']),
      available: json['available'] == true,
    );
  }
}

class BookingSlot {
  const BookingSlot({
    required this.time,
    required this.available,
    required this.capsters,
  });

  final String time;
  final bool available;
  final List<SlotCapster> capsters;

  List<SlotCapster> get availableCapsters =>
      capsters.where((SlotCapster c) => c.available).toList(growable: false);

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    final Object? rawCapsters = json['capsters'];

    return BookingSlot(
      time: _toText(json['time']),
      available: json['available'] == true,
      capsters: rawCapsters is List
          ? rawCapsters
                .whereType<Map<String, dynamic>>()
                .map(SlotCapster.fromJson)
                .toList(growable: false)
          : const <SlotCapster>[],
    );
  }
}

class StoreSlots {
  const StoreSlots({
    required this.idStore,
    required this.date,
    required this.slots,
  });

  final String idStore;
  final DateTime date;
  final List<BookingSlot> slots;

  factory StoreSlots.fromJson(Map<String, dynamic> json) {
    final Object? rawSlots = json['slots'];

    return StoreSlots(
      idStore: _toText(json['id_store']),
      date: DateTime.tryParse(_toText(json['date']))?.toLocal() ??
          DateTime.now(),
      slots: rawSlots is List
          ? rawSlots
                .whereType<Map<String, dynamic>>()
                .map(BookingSlot.fromJson)
                .toList(growable: false)
          : const <BookingSlot>[],
    );
  }
}

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.idStore,
    required this.type,
    required this.status,
    this.description,
  });

  final String id;
  final String name;
  final double price;
  final String idStore;
  final ProductType type;
  final String status;
  final String? description;

  bool get isActive => status.toLowerCase().trim() == 'active';

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: _toText(json['id']),
      name: _toText(json['name'] ?? json['string']),
      price: _toDouble(json['price']),
      idStore: _toText(json['id_store']),
      type: ProductType.fromJson(json['type'] as String?),
      status: _toText(json['status']),
      description: json['description'] as String?,
    );
  }
}

class BookingStoreInfo {
  const BookingStoreInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  final String id;
  final String name;
  final String address;
  final String phoneNumber;

  factory BookingStoreInfo.fromJson(Map<String, dynamic> json) {
    return BookingStoreInfo(
      id: _toText(json['id']),
      name: _toText(json['name']),
      address: _toText(json['address']),
      phoneNumber: _toText(json['phone_number']),
    );
  }
}

class BookingCapsterInfo {
  const BookingCapsterInfo({required this.id, required this.name});

  final String id;
  final String name;

  factory BookingCapsterInfo.fromJson(Map<String, dynamic> json) {
    return BookingCapsterInfo(
      id: _toText(json['id']),
      name: _toText(json['name']),
    );
  }
}

class BookingServiceInfo {
  const BookingServiceInfo({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfo(
      id: _toText(json['id']),
      name: _toText(json['name'] ?? json['string']),
      price: _toDouble(json['price']),
    );
  }
}

class BookingResult {
  const BookingResult({
    required this.idBooking,
    required this.qrCode,
    required this.bookingDate,
    required this.appServiceFee,
    required this.totalPrice,
    required this.store,
    required this.capster,
    required this.services,
  });

  final String idBooking;
  final String qrCode;
  final DateTime bookingDate;
  final int appServiceFee;
  final double totalPrice;
  final BookingStoreInfo store;
  final BookingCapsterInfo capster;
  final List<BookingServiceInfo> services;

  double get subTotal => services.fold<double>(
    0,
    (double sum, BookingServiceInfo s) => sum + s.price,
  );

  double get grandTotal => totalPrice + appServiceFee;

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    final Object? rawServices = json['service'];
    final Object? rawStore = json['store'];
    final Object? rawCapster = json['capster'];

    return BookingResult(
      idBooking: _toText(json['id_booking']),
      qrCode: _toText(json['qr_code']),
      bookingDate:
          DateTime.tryParse(_toText(json['booking_date']))?.toLocal() ??
          DateTime.now(),
      appServiceFee: _toInt(json['app_service_fee']),
      totalPrice: _toDouble(json['total_price']),
      store: rawStore is Map<String, dynamic>
          ? BookingStoreInfo.fromJson(rawStore)
          : const BookingStoreInfo(
              id: '',
              name: '',
              address: '',
              phoneNumber: '',
            ),
      capster: rawCapster is Map<String, dynamic>
          ? BookingCapsterInfo.fromJson(rawCapster)
          : const BookingCapsterInfo(id: '', name: ''),
      services: rawServices is List
          ? rawServices
                .whereType<Map<String, dynamic>>()
                .map(BookingServiceInfo.fromJson)
                .toList(growable: false)
          : const <BookingServiceInfo>[],
    );
  }
}
