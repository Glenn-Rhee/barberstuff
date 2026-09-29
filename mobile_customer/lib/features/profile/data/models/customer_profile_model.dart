import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';

class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.gender,
    required super.memberPoints,
    required super.tier,
    super.imageUrl,
    super.dateOfBirth,
  });

  /// `premium_type` dari backend. Nilai tak dikenal dianggap silver.
  static MemberTier tierFromJson(String? value) {
    return MemberTier.values.firstWhere(
      (MemberTier tier) => tier.name == value?.toLowerCase().trim(),
      orElse: () => MemberTier.silver,
    );
  }

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    final String? image = json['image_url'] as String?;

    return CustomerProfileModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      memberPoints: (json['member_points'] as num?)?.toInt() ?? 0,
      tier: tierFromJson(json['premium_type'] as String?),
      imageUrl: image == null || image.isEmpty ? null : image,
      dateOfBirth: DateTime.tryParse((json['date_of_birth'] as String?) ?? ''),
    );
  }
}
