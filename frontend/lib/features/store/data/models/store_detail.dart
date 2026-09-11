import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';

String _text(Object? value) => value is String ? value : '';

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

int _toInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}

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

  factory StoreReview.fromJson(Map<String, dynamic> json) {
    final Object? user = json['user'];
    final Map<String, dynamic> raw = user is Map<String, dynamic>
        ? user
        : const <String, dynamic>{};

    return StoreReview(
      id: _text(json['id']),
      message: _text(json['message']),
      rating: _toInt(json['rating']),
      userName: _text(raw['name']),
      userImageUrl: _text(raw['image_url']),
      userTier: _text(raw['premium_type']),
    );
  }
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

  factory CapsterItem.fromJson(Map<String, dynamic> json) {
    return CapsterItem(
      id: _text(json['id']),
      name: _text(json['name']),
      imageUrl: _text(json['image_url']),
      avgRating: _toDouble(json['avg_rating']),
      status: _text(json['status']),
    );
  }
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
  final DateTime? openHour;
  final DateTime? closeHour;

  bool get isOpen => status.toLowerCase().trim() == 'open';
  bool get isLite => storeType.toLowerCase().trim() == 'lite';
  int get reviewCount => reviews.length;

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    final Object? rawReviews = json['review'];

    return StoreDetail(
      id: _text(json['id']),
      name: _text(json['name']),
      phoneNumber: _text(json['phone_number']),
      address: _text(json['address']),
      bannerUrl: _text(json['banner_url']),
      description: _text(json['description']),
      storeType: _text(json['store_type']),
      status: _text(json['status']),
      avgRating: _toDouble(json['avg_rating']),
      totalService: _toInt(json['total_service']),
      totalCapster: _toInt(json['total_capster']),
      totalPackage: _toInt(json['total_package']),
      coordinate: StoreCoordinate.parse(json['coordinate']),
      openHour: DateTime.tryParse(_text(json['open_hour']))?.toLocal(),
      closeHour: DateTime.tryParse(_text(json['close_hour']))?.toLocal(),
      reviews: rawReviews is List
          ? rawReviews
                .whereType<Map<String, dynamic>>()
                .map(StoreReview.fromJson)
                .toList(growable: false)
          : const <StoreReview>[],
    );
  }
}
