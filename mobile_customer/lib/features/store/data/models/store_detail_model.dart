import 'package:mobile_barberstuff/core/utils/json_value.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';

/// Jam operasional adalah jam dinding toko, bukan titik waktu: backend memakai
/// Hour()/Minute() apa adanya lalu menanamkannya ke zona toko. Penanda zona pada
/// string dibuang, bukan dikonversi, supaya 10:00 tetap terbaca 10:00.
DateTime? _wallClock(Object? value) {
  final String text = jsonText(value).trim();
  if (text.isEmpty) return null;

  return DateTime.tryParse(
    text.replaceFirst(RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$'), ''),
  );
}

class StoreReviewModel extends StoreReview {
  const StoreReviewModel({
    required super.id,
    required super.message,
    required super.rating,
    required super.userName,
    required super.userImageUrl,
    required super.userTier,
  });

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user =
        jsonMap(json['user']) ?? const <String, dynamic>{};

    return StoreReviewModel(
      id: jsonText(json['id']),
      message: jsonText(json['message']),
      rating: jsonInt(json['rating']),
      userName: jsonText(user['name']),
      userImageUrl: jsonText(user['image_url']),
      userTier: jsonText(user['premium_type']),
    );
  }
}

class CapsterItemModel extends CapsterItem {
  const CapsterItemModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.avgRating,
    required super.status,
  });

  factory CapsterItemModel.fromJson(Map<String, dynamic> json) {
    return CapsterItemModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
      imageUrl: jsonText(json['image_url']),
      avgRating: jsonDouble(json['avg_rating']),
      status: jsonText(json['status']),
    );
  }
}

class StoreDetailModel extends StoreDetail {
  const StoreDetailModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.address,
    required super.bannerUrl,
    required super.description,
    required super.storeType,
    required super.status,
    required super.avgRating,
    required super.totalService,
    required super.totalCapster,
    required super.totalPackage,
    required super.reviews,
    super.coordinate,
    super.openHour,
    super.closeHour,
  });

  factory StoreDetailModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
      phoneNumber: jsonText(json['phone_number']),
      address: jsonText(json['address']),
      bannerUrl: jsonText(json['banner_url']),
      description: jsonText(json['description']),
      storeType: jsonText(json['store_type']),
      status: jsonText(json['status']),
      avgRating: jsonDouble(json['avg_rating']),
      totalService: jsonInt(json['total_service']),
      totalCapster: jsonInt(json['total_capster']),
      totalPackage: jsonInt(json['total_package']),
      coordinate: StoreCoordinateModel.fromJson(json['coordinate']),
      openHour: _wallClock(json['open_hour']),
      closeHour: _wallClock(json['close_hour']),
      reviews: jsonList(json['review'], StoreReviewModel.fromJson),
    );
  }
}
