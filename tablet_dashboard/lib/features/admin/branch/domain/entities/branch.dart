import 'package:tablet_dashboard/core/utils/date_format.dart';

// Tipe toko di backend (store_type)
enum BranchType {
  lite('lite', 'Lite'),
  premium('premium', 'Premium');

  const BranchType(this.api, this.label);

  final String api;
  final String label;

  static BranchType parse(String? value) =>
      values.where((t) => t.api == value).firstOrNull ?? BranchType.lite;
}

// Zona waktu toko, wajib saat buat cabang
enum BranchTimezone {
  jakarta('Asia/Jakarta', 'WIB (Asia/Jakarta)'),
  makassar('Asia/Makassar', 'WITA (Asia/Makassar)'),
  jayapura('Asia/Jayapura', 'WIT (Asia/Jayapura)');

  const BranchTimezone(this.api, this.label);

  final String api;
  final String label;
}

// Cabang lengkap dari GET /store (khusus admin)
class Branch {
  const Branch({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.description,
    this.bannerUrl,
    this.openHour,
    this.closeHour,
    this.latitude,
    this.longitude,
    this.type = BranchType.lite,
    this.open = true,
    this.totalService = 0,
    this.totalPackage = 0,
    this.totalCapster = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final coordinate = _coordinateOf(json['coordinate']);
    return Branch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '-',
      phone: _text(json['phone_number']),
      address: _text(json['address']),
      description: _text(json['description']),
      bannerUrl: _text(json['banner_url']),
      openHour: DateFormatId.clockOf(json['open_hour']),
      closeHour: DateFormatId.clockOf(json['close_hour']),
      latitude: coordinate?.$1,
      longitude: coordinate?.$2,
      type: BranchType.parse(json['store_type'] as String?),
      open: (json['status'] as String? ?? 'open') == 'open',
      totalService: (json['total_service'] as num?)?.toInt() ?? 0,
      totalPackage: (json['total_package'] as num?)?.toInt() ?? 0,
      totalCapster: (json['total_capster'] as num?)?.toInt() ?? 0,
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review'] as List?)?.length ?? 0,
      createdAt: DateTime.tryParse('${json['created_at']}'),
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? description;

  // URL presigned, kedaluwarsa 30 menit, cuma untuk ditampilkan
  final String? bannerUrl;

  // Format "09:00"
  final String? openHour;
  final String? closeHour;

  final double? latitude;
  final double? longitude;
  final BranchType type;

  // Status toko dari admin (open / close)
  final bool open;

  // Jumlah dari backend. total_service & total_package ikut menghitung
  // layanan yang sudah dihapus, jadi detail cabang pakai daftar aslinya
  final int totalService;
  final int totalPackage;
  final int totalCapster;

  // Backend kasih 5.0 kalau belum ada ulasan
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;

  bool get hasCoordinate => latitude != null && longitude != null;

  // "09:00 - 21:00"
  String get hours => '${openHour ?? '--:--'} - ${closeHour ?? '--:--'}';

  // "4.9", atau "Baru" kalau belum ada ulasan
  String get ratingLabel =>
      reviewCount == 0 ? 'Baru' : rating.toStringAsFixed(1);

  // "-6.2812736,106.930027" -> (-6.28, 106.93)
  static (double, double)? _coordinateOf(Object? value) {
    final parts = '${value ?? ''}'.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final long = double.tryParse(parts[1].trim());
    return lat == null || long == null ? null : (lat, long);
  }

  static String? _text(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
