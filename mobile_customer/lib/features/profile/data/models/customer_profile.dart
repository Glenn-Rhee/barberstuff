enum MemberTier {
  silver(threshold: 0),
  gold(threshold: 500),
  platinum(threshold: 1500);

  const MemberTier({required this.threshold});

  final int threshold;

  static MemberTier fromJson(String? value) {
    return MemberTier.values.firstWhere(
      (MemberTier tier) => tier.name == value?.toLowerCase().trim(),
      orElse: () => MemberTier.silver,
    );
  }

  MemberTier? get next {
    final int index = MemberTier.values.indexOf(this);
    return index + 1 < MemberTier.values.length
        ? MemberTier.values[index + 1]
        : null;
  }
}

class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.memberPoints,
    required this.tier,
    this.imageUrl,
    this.dateOfBirth,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final int memberPoints;
  final MemberTier tier;
  final String? imageUrl;
  final DateTime? dateOfBirth;

  int get pointsToNextTier {
    final MemberTier? next = tier.next;
    if (next == null) return 0;
    final int remaining = next.threshold - memberPoints;
    return remaining > 0 ? remaining : 0;
  }

  double get tierProgress {
    final MemberTier? next = tier.next;
    if (next == null) return 1;

    final int span = next.threshold - tier.threshold;
    if (span <= 0) return 1;

    return ((memberPoints - tier.threshold) / span).clamp(0.0, 1.0);
  }

  CustomerProfile copyWith({MemberTier? tier, int? memberPoints}) {
    return CustomerProfile(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
      memberPoints: memberPoints ?? this.memberPoints,
      tier: tier ?? this.tier,
      imageUrl: imageUrl,
      dateOfBirth: dateOfBirth,
    );
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    final String? image = json['image_url'] as String?;

    return CustomerProfile(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      memberPoints: (json['member_points'] as num?)?.toInt() ?? 0,
      tier: MemberTier.fromJson(json['premium_type'] as String?),
      imageUrl: image == null || image.isEmpty ? null : image,
      dateOfBirth: DateTime.tryParse((json['date_of_birth'] as String?) ?? ''),
    );
  }
}
