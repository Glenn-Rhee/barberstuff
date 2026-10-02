// Role yang boleh masuk tablet, tiap role punya dashboard sendiri
enum StaffRole {
  cashier('Kasir'),
  admin('Admin'),
  mitra('Mitra');

  const StaffRole(this.label);

  final String label;

  // null kalau role tidak boleh pakai tablet (mis. customer)
  static StaffRole? parse(String? value) =>
      values.where((r) => r.name == value).firstOrNull;
}

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
    storeId: (json['id_store'] ?? json['store_id']) as String? ?? '',
  );

  StaffRole? get staffRole => StaffRole.parse(role);

  String get roleLabel => switch (role) {
    'cashier' => 'Kasir Barberstuff',
    'admin' => 'Administrator',
    'mitra' => 'Mitra Barberstuff',
    _ => role,
  };
}
