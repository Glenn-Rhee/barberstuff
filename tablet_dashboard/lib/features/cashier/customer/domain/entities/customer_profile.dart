// Pelanggan di histori (GET /customer). Member = pakai aplikasi (punya
// akun / email), Reguler = didaftarkan kasir tanpa aplikasi
class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.photoUrl,
    this.points = 0,
    this.totalVisited = 0,
    this.lastVisitedAt,
    this.favoriteService,
    this.favoriteCapster,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '-',
        phone: _text(json['phone_number']),
        email: _text(json['email']),
        photoUrl: _text(json['image_url']),
        points: (json['member_points'] as num?)?.toInt() ?? 0,
        totalVisited: (json['total_visited'] as num?)?.toInt() ?? 0,
        lastVisitedAt: DateTime.tryParse(
          json['last_visited_at'] as String? ?? '',
        )?.toLocal(),
        favoriteService: _text(json['service_favorite']),
        favoriteCapster: _text(json['capster_favorite']),
      );

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final int points;
  final int totalVisited;
  final DateTime? lastVisitedAt;
  final String? favoriteService;
  final String? favoriteCapster;

  bool get isMember => email != null;
  String get statusLabel => isMember ? 'Member' : 'Reguler';

  // Kode pendek dari UUID, mis. USR-9FD21E
  String get code {
    final head = id.replaceAll('-', '');
    return 'USR-${(head.length >= 6 ? head.substring(0, 6) : head).toUpperCase()}';
  }

  static String? _text(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
