// Capster toko (GET /capster), juga ikut di data booking
class Capster {
  const Capster({
    required this.id,
    required this.name,
    this.photoUrl,
    this.rating = 0,
    this.active = true,
  });

  factory Capster.fromJson(Map<String, dynamic> json) => Capster(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '-',
    photoUrl: (json['image_url'] as String?)?.trim().isEmpty ?? true
        ? null
        : json['image_url'] as String?,
    rating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
    active: (json['status'] as String? ?? 'active') == 'active',
  );

  final String id;
  final String name;
  final String? photoUrl;
  final double rating;
  final bool active;
}
