// Pelanggan di data booking (GET /booking)
class BookingCustomer {
  const BookingCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.premiumType,
    this.memberPoints = 0,
    this.favoriteService,
  });

  factory BookingCustomer.fromJson(Map<String, dynamic> json) =>
      BookingCustomer(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Pelanggan',
        phone: json['phone_number'] as String?,
        premiumType: (json['premium_type'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['premium_type'] as String?,
        memberPoints: (json['member_points'] as num?)?.toInt() ?? 0,
        favoriteService:
            (json['service_favorite'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['service_favorite'] as String?,
      );

  final String id;
  final String name;
  final String? phone;
  final String? premiumType;
  final int memberPoints;
  final String? favoriteService;

  // Backend kirim "reguler" kalau pelanggan belum punya tipe premium
  bool get isMember =>
      premiumType != null && premiumType!.toLowerCase() != 'reguler';

  String get membershipLabel => isMember ? 'Member · $premiumType' : 'Reguler';
}
