import 'package:mobile_barberstuff/core/utils/json_value.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';

/// Satu item `GET /booking/customer`. Endpoint itu tidak mengirim status,
/// kode QR, maupun biaya layanan, jadi:
/// - status diambil dari filter `status_booking` yang dipakai saat fetch;
/// - kode QR dan biaya diambil dari `local` (jurnal perangkat) kalau booking
///   ini dibuat dari perangkat ini.
class CustomerBookingModel extends BookingRecord {
  const CustomerBookingModel({
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
    super.staffId,
    super.status,
    super.canceled,
    super.review,
  });

  factory CustomerBookingModel.fromJson(
    Map<String, dynamic> json, {
    required BookingStatus status,
    BookingRecord? local,
  }) {
    final String id = jsonText(json['id']);
    final Map<String, dynamic> store =
        jsonMap(json['store']) ?? const <String, dynamic>{};
    final Map<String, dynamic> capster =
        jsonMap(json['capster']) ?? const <String, dynamic>{};
    final Map<String, dynamic> staff =
        jsonMap(json['staff']) ?? const <String, dynamic>{};
    final Map<String, dynamic>? rating = jsonMap(json['rating']);
    final DateTime scheduledAt =
        DateTime.tryParse(jsonText(json['booking_date']))?.toLocal() ??
        local?.scheduledAt ??
        DateTime.now();

    return CustomerBookingModel(
      id: id,
      // Backend membuat QR sebagai "bk" + id booking (booking_service.go).
      // Ikuti format itu selama endpoint daftar belum mengirim `qr_code`.
      qrCode: local?.qrCode ?? 'bk$id',
      scheduledAt: scheduledAt,
      createdAt: local?.createdAt ?? scheduledAt,
      storeId: jsonText(store['id']),
      storeName: jsonText(store['name']),
      storeAddress: jsonText(store['address']),
      storePhone: jsonText(store['phone_number']),
      capsterId: jsonText(capster['id']),
      capsterName: jsonText(capster['name']),
      staffId: jsonText(staff['id']),
      lines: jsonList(
        json['service'],
        (Map<String, dynamic> s) => BookingLine(
          id: jsonText(s['id']),
          name: jsonText(s['name']),
          price: jsonDouble(s['price']),
        ),
      ),
      appServiceFee: local?.appServiceFee ?? 0,
      totalPrice: jsonDouble(json['total_price']),
      status: status,
      canceled: status == BookingStatus.canceled,
      review: rating == null
          ? null
          : BookingReview(
              capster: jsonInt(rating['capster_rating']),
              cashier: jsonInt(rating['staff_rating']),
              store: jsonInt(rating['store_rating']),
              message: jsonText(rating['message']),
            ),
    );
  }

  /// Nilai `status_booking` dari backend.
  static BookingStatus statusFromJson(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'progress':
        return BookingStatus.progress;
      case 'completed':
        return BookingStatus.completed;
      case 'canceled':
        return BookingStatus.canceled;
      default:
        return BookingStatus.booked;
    }
  }
}
