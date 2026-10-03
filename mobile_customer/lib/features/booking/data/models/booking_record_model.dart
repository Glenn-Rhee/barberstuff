import 'package:mobile_barberstuff/features/booking/data/models/booking_result_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';

class BookingLineModel extends BookingLine {
  const BookingLineModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory BookingLineModel.fromJson(Map<String, dynamic> json) =>
      BookingLineModel(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );

  factory BookingLineModel.fromEntity(BookingLine line) =>
      BookingLineModel(id: line.id, name: line.name, price: line.price);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'price': price,
  };
}

class BookingReviewModel extends BookingReview {
  const BookingReviewModel({
    required super.capster,
    required super.cashier,
    required super.store,
    required super.message,
  });

  factory BookingReviewModel.fromJson(Map<String, dynamic> json) =>
      BookingReviewModel(
        capster: (json['capster'] as num?)?.toInt() ?? 0,
        cashier: (json['cashier'] as num?)?.toInt() ?? 0,
        store: (json['store'] as num?)?.toInt() ?? 0,
        message: '${json['message'] ?? ''}',
      );

  factory BookingReviewModel.fromEntity(BookingReview review) =>
      BookingReviewModel(
        capster: review.capster,
        cashier: review.cashier,
        store: review.store,
        message: review.message,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'capster': capster,
    'cashier': cashier,
    'store': store,
    'message': message,
  };
}

/// Bentuk booking di jurnal perangkat.
class BookingRecordModel extends BookingRecord {
  const BookingRecordModel({
    required super.id,
    required super.qrCode,
    required super.scheduledAt,
    required super.createdAt,
    required super.storeId,
    required super.storeName,
    required super.storeAddress,
    required super.storePhone,
    required super.capsterId,
    required super.capsterName,
    required super.lines,
    required super.appServiceFee,
    required super.totalPrice,
    super.canceled,
    super.review,
  });

  /// Hasil `POST /booking/`. Nama capster dari layar dipakai lebih dulu
  /// karena respons server kadang mengosongkannya.
  factory BookingRecordModel.fromResult(
    BookingResultModel result, {
    required String capsterId,
    required String capsterName,
  }) {
    return BookingRecordModel(
      id: result.idBooking,
      qrCode: result.qrCode,
      scheduledAt: result.bookingDate,
      createdAt: DateTime.now(),
      storeId: result.store.id,
      storeName: result.store.name,
      storeAddress: result.store.address,
      storePhone: result.store.phoneNumber,
      capsterId: capsterId.isNotEmpty ? capsterId : result.capster.id,
      capsterName: capsterName.isNotEmpty ? capsterName : result.capster.name,
      lines: result.services
          .map(
            (BookingServiceInfoModel s) =>
                BookingLine(id: s.id, name: s.name, price: s.price),
          )
          .toList(growable: false),
      appServiceFee: result.appServiceFee,
      totalPrice: result.totalPrice,
    );
  }

  factory BookingRecordModel.fromJson(Map<String, dynamic> json) {
    final Object? rawLines = json['lines'];

    return BookingRecordModel(
      id: '${json['id'] ?? ''}',
      qrCode: '${json['qr_code'] ?? ''}',
      scheduledAt:
          DateTime.tryParse('${json['scheduled_at'] ?? ''}') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
      storeId: '${json['store_id'] ?? ''}',
      storeName: '${json['store_name'] ?? ''}',
      storeAddress: '${json['store_address'] ?? ''}',
      storePhone: '${json['store_phone'] ?? ''}',
      capsterId: '${json['capster_id'] ?? ''}',
      capsterName: '${json['capster_name'] ?? ''}',
      lines: rawLines is List
          ? rawLines
                .whereType<Map<String, dynamic>>()
                .map(BookingLineModel.fromJson)
                .toList(growable: false)
          : const <BookingLine>[],
      appServiceFee: (json['app_service_fee'] as num?)?.toInt() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      canceled: json['canceled'] == true,
      review: json['review'] is Map<String, dynamic>
          ? BookingReviewModel.fromJson(json['review'] as Map<String, dynamic>)
          : null,
    );
  }

  factory BookingRecordModel.fromEntity(BookingRecord record) {
    return BookingRecordModel(
      id: record.id,
      qrCode: record.qrCode,
      scheduledAt: record.scheduledAt,
      createdAt: record.createdAt,
      storeId: record.storeId,
      storeName: record.storeName,
      storeAddress: record.storeAddress,
      storePhone: record.storePhone,
      capsterId: record.capsterId,
      capsterName: record.capsterName,
      lines: record.lines,
      appServiceFee: record.appServiceFee,
      totalPrice: record.totalPrice,
      canceled: record.canceled,
      review: record.review,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'qr_code': qrCode,
    'scheduled_at': scheduledAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'store_id': storeId,
    'store_name': storeName,
    'store_address': storeAddress,
    'store_phone': storePhone,
    'capster_id': capsterId,
    'capster_name': capsterName,
    'lines': lines
        .map((BookingLine l) => BookingLineModel.fromEntity(l).toJson())
        .toList(growable: false),
    'app_service_fee': appServiceFee,
    'total_price': totalPrice,
    'canceled': canceled,
    'review': review == null
        ? null
        : BookingReviewModel.fromEntity(review!).toJson(),
  };
}
