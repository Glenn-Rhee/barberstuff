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

<<<<<<< HEAD
  // Status di server: inactive = tidak muncul di aplikasi pelanggan
  // dan tidak bisa dipesan (dipakai untuk "Tidak Hadir")
=======
  // inactive = tidak muncul & tidak bisa dipesan (dipakai untuk Tidak Hadir)
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  final bool active;

  Capster copyWith({bool? active}) => Capster(
    id: id,
    name: name,
    photoUrl: photoUrl,
    rating: rating,
    active: active ?? this.active,
  );
}
