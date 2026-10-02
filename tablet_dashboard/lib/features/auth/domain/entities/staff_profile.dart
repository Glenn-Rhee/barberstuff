class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.storeId,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String storeId;

  factory StaffProfile.fromJson(Map<String, dynamic> json) => StaffProfile(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '-',
    email: json['email'] as String? ?? '-',
    role: json['role'] as String? ?? '',
    storeId: json['store_id'] as String? ?? '',
  );

  String get roleLabel => switch (role) {
    'cashier' => 'Kasir Barberstuff',
    'admin' => 'Administrator',
    'mitra' => 'Mitra Barberstuff',
    _ => role,
  };
}
