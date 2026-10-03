import 'package:mobile_barberstuff/core/utils/json_value.dart';

/// Respons `POST /booking/`. Hanya dipakai di lapisan data: repository
/// langsung mengubahnya jadi BookingRecord.
class BookingResultModel {
  const BookingResultModel({
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

  /// Sudah termasuk [appServiceFee] dan potongan promo. Tampilkan apa adanya.
  final double totalPrice;
  final BookingStoreInfoModel store;
  final BookingCapsterInfoModel capster;
  final List<BookingServiceInfoModel> services;

  factory BookingResultModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? store = jsonMap(json['store']);
    final Map<String, dynamic>? capster = jsonMap(json['capster']);

    return BookingResultModel(
      idBooking: jsonText(json['id_booking']),
      qrCode: jsonText(json['qr_code']),
      bookingDate:
          DateTime.tryParse(jsonText(json['booking_date']))?.toLocal() ??
          DateTime.now(),
      appServiceFee: jsonInt(json['app_service_fee']),
      totalPrice: jsonDouble(json['total_price']),
      store: store != null
          ? BookingStoreInfoModel.fromJson(store)
          : const BookingStoreInfoModel(
              id: '',
              name: '',
              address: '',
              phoneNumber: '',
            ),
      capster: capster != null
          ? BookingCapsterInfoModel.fromJson(capster)
          : const BookingCapsterInfoModel(id: '', name: ''),
      services: jsonList(json['service'], BookingServiceInfoModel.fromJson),
    );
  }
}

class BookingStoreInfoModel {
  const BookingStoreInfoModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  final String id;
  final String name;
  final String address;
  final String phoneNumber;

  factory BookingStoreInfoModel.fromJson(Map<String, dynamic> json) {
    return BookingStoreInfoModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
      address: jsonText(json['address']),
      phoneNumber: jsonText(json['phone_number']),
    );
  }
}

class BookingCapsterInfoModel {
  const BookingCapsterInfoModel({required this.id, required this.name});

  final String id;
  final String name;

  factory BookingCapsterInfoModel.fromJson(Map<String, dynamic> json) {
    return BookingCapsterInfoModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
    );
  }
}

class BookingServiceInfoModel {
  const BookingServiceInfoModel({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  factory BookingServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfoModel(
      id: jsonText(json['id']),
      name: jsonText(json['name'] ?? json['string']),
      price: jsonDouble(json['price']),
    );
  }
}
