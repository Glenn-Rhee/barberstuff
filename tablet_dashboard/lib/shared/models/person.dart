/// The signed-in cashier (`GET /profile/staff`).
class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.name,
    required this.storeId,
    required this.role,
    required this.email,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) => StaffProfile(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '-',
    storeId: json['id_store'] as String? ?? '',
    role: json['role'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );

  final String id;
  final String name;
  final String storeId;
  final String role;
  final String email;

  String get roleLabel => switch (role) {
    'cashier' => 'Kasir',
    'admin' => 'Admin',
    'mitra' => 'Mitra',
    _ => role,
  };
}

/// A capster of the store (`GET /capster`), also embedded in bookings.
class Capster {
  const Capster({required this.id, required this.name, this.photoUrl, this.rating = 0, this.active = true});

  factory Capster.fromJson(Map<String, dynamic> json) => Capster(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '-',
    photoUrl: (json['image_url'] as String?)?.trim().isEmpty ?? true ? null : json['image_url'] as String?,
    rating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
    active: (json['status'] as String? ?? 'active') == 'active',
  );

  final String id;
  final String name;
  final String? photoUrl;
  final double rating;
  final bool active;
}

/// Customer attached to a booking (`GET /booking`).
class BookingCustomer {
  const BookingCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.premiumType,
    this.memberPoints = 0,
    this.favoriteService,
  });

  factory BookingCustomer.fromJson(Map<String, dynamic> json) => BookingCustomer(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Pelanggan',
    phone: json['phone_number'] as String?,
    premiumType: (json['premium_type'] as String?)?.trim().isEmpty ?? true ? null : json['premium_type'] as String?,
    memberPoints: (json['member_points'] as num?)?.toInt() ?? 0,
    favoriteService: (json['service_favorite'] as String?)?.trim().isEmpty ?? true
        ? null
        : json['service_favorite'] as String?,
  );

  final String id;
  final String name;
  final String? phone;
  final String? premiumType;
  final int memberPoints;
  final String? favoriteService;

  bool get isMember => premiumType != null;
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final second = parts.length > 1 ? parts[1][0] : '';
  return (first + second).toUpperCase();
}
