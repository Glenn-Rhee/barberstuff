import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

class BookingLine {
  const BookingLine({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'price': price,
  };

  factory BookingLine.fromJson(Map<String, dynamic> json) => BookingLine(
    id: '${json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}

/// Ulasan yang sudah dikirim, disimpan utuh supaya bisa dilihat lagi.
class BookingReview {
  const BookingReview({
    required this.capster,
    required this.cashier,
    required this.store,
    required this.message,
  });

  final int capster;
  final int cashier;
  final int store;
  final String message;

  double get average => (capster + cashier + store) / 3;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'capster': capster,
    'cashier': cashier,
    'store': store,
    'message': message,
  };

  factory BookingReview.fromJson(Map<String, dynamic> json) => BookingReview(
    capster: (json['capster'] as num?)?.toInt() ?? 0,
    cashier: (json['cashier'] as num?)?.toInt() ?? 0,
    store: (json['store'] as num?)?.toInt() ?? 0,
    message: '${json['message'] ?? ''}',
  );
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

/// Satu booking untuk struk, beranda, dan riwayat. Sumbernya bisa hasil
/// `POST /booking/` ([BookingRecord.fromResult], disimpan di jurnal perangkat)
/// atau daftar `GET /booking/customer` ([BookingRecord.fromServer]).
class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.qrCode,
    required this.scheduledAt,
    required this.createdAt,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.capsterId,
    required this.capsterName,
    required this.lines,
    required this.appServiceFee,
    required this.totalPrice,
    this.staffId = '',
    this.status,
    this.canceled = false,
    this.review,
  });

  final String id;
  final String qrCode;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String capsterId;
  final String capsterName;
  final List<BookingLine> lines;

  /// 0 berarti tidak diketahui: daftar dari server tidak mengirim biaya ini.
  final int appServiceFee;

  /// `total_price` dari backend, sudah termasuk [appServiceFee] dan potongan
  /// promo. Tampilkan apa adanya, jangan ditambah atau dikurangi lagi.
  final double totalPrice;

  /// Kasir yang menangani, dibutuhkan untuk rating. Kosong untuk booking lokal.
  final String staffId;

  /// Status dari server. null untuk booking yang baru dibuat di perangkat.
  final BookingStatus? status;

  final bool canceled;
  final BookingReview? review;

  double? get reviewScore => review?.average;

  String get serviceName => lines.map((BookingLine l) => l.name).join(' - ');

  bool get isReviewed => reviewScore != null;

  BookingStatus statusAt(DateTime now) {
    final BookingStatus? known = status;
    if (known != null) return known;
    if (canceled) return BookingStatus.canceled;
    return scheduledAt.isAfter(now)
        ? BookingStatus.booked
        : BookingStatus.completed;
  }

  BookingHistory toHistory(DateTime now) => BookingHistory(
    id: id,
    serviceName: serviceName,
    storeName: storeName,
    date: scheduledAt,
    price: totalPrice.round(),
    status: statusAt(now),
    reviewScore: reviewScore,
  );

  BookingRecord copyWith({bool? canceled, BookingReview? review}) {
    return BookingRecord(
      id: id,
      qrCode: qrCode,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      storeId: storeId,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      capsterId: capsterId,
      capsterName: capsterName,
      lines: lines,
      appServiceFee: appServiceFee,
      totalPrice: totalPrice,
      staffId: staffId,
      status: status,
      canceled: canceled ?? this.canceled,
      review: review ?? this.review,
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
    'lines': lines.map((BookingLine l) => l.toJson()).toList(growable: false),
    'app_service_fee': appServiceFee,
    'total_price': totalPrice,
    'canceled': canceled,
    'review': review?.toJson(),
  };

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final Object? rawLines = json['lines'];

    return BookingRecord(
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
                .map(BookingLine.fromJson)
                .toList(growable: false)
          : const <BookingLine>[],
      appServiceFee: (json['app_service_fee'] as num?)?.toInt() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      canceled: json['canceled'] == true,
      review: json['review'] is Map<String, dynamic>
          ? BookingReview.fromJson(json['review'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Satu item `GET /booking/customer`. Endpoint itu tidak mengirim status,
  /// kode QR, maupun biaya layanan, jadi:
  /// - [status] diambil dari filter `status_booking` yang dipakai saat fetch;
  /// - kode QR dan biaya diambil dari [local] (jurnal perangkat) kalau booking
  ///   ini dibuat dari perangkat ini.
  factory BookingRecord.fromServer(
    Map<String, dynamic> json, {
    required BookingStatus status,
    BookingRecord? local,
  }) {
    final String id = _toText(json['id']);
    final Object? rawServices = json['service'];
    final Map<String, dynamic> store = json['store'] is Map<String, dynamic>
        ? json['store'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final Map<String, dynamic> capster =
        json['capster'] is Map<String, dynamic>
        ? json['capster'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final Map<String, dynamic> staff = json['staff'] is Map<String, dynamic>
        ? json['staff'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final Object? rawRating = json['rating'];
    final DateTime scheduledAt =
        DateTime.tryParse(_toText(json['booking_date']))?.toLocal() ??
        local?.scheduledAt ??
        DateTime.now();

    return BookingRecord(
      id: id,
      // Backend membuat QR sebagai "bk" + id booking (booking_service.go).
      // Ikuti format itu selama endpoint daftar belum mengirim `qr_code`.
      qrCode: local?.qrCode ?? 'bk$id',
      scheduledAt: scheduledAt,
      createdAt: local?.createdAt ?? scheduledAt,
      storeId: _toText(store['id']),
      storeName: _toText(store['name']),
      storeAddress: _toText(store['address']),
      storePhone: _toText(store['phone_number']),
      capsterId: _toText(capster['id']),
      capsterName: _toText(capster['name']),
      staffId: _toText(staff['id']),
      lines: rawServices is List
          ? rawServices
                .whereType<Map<String, dynamic>>()
                .map(
                  (Map<String, dynamic> s) => BookingLine(
                    id: _toText(s['id']),
                    name: _toText(s['name']),
                    price: _toDouble(s['price']),
                  ),
                )
                .toList(growable: false)
          : const <BookingLine>[],
      appServiceFee: local?.appServiceFee ?? 0,
      totalPrice: _toDouble(json['total_price']),
      status: status,
      canceled: status == BookingStatus.canceled,
      review: rawRating is Map<String, dynamic>
          ? BookingReview(
              capster: _toInt(rawRating['capster_rating']),
              cashier: _toInt(rawRating['staff_rating']),
              store: _toInt(rawRating['store_rating']),
              message: _toText(rawRating['message']),
            )
          : null,
    );
  }

  factory BookingRecord.fromResult(
    BookingResult result, {
    required String capsterId,
    required String capsterName,
  }) {
    return BookingRecord(
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
            (BookingServiceInfo s) =>
                BookingLine(id: s.id, name: s.name, price: s.price),
          )
          .toList(growable: false),
      appServiceFee: result.appServiceFee,
      totalPrice: result.totalPrice,
    );
  }
}
