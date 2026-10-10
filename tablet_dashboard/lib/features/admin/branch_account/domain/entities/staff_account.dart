import 'package:tablet_dashboard/features/auth/login/domain/entities/staff_profile.dart';

// Akun login cabang (GET /staff), maks. 1 kasir + 1 mitra per cabang
class StaffAccount {
  const StaffAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory StaffAccount.fromJson(Map<String, dynamic> json) => StaffAccount(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '-',
    email: json['email'] as String? ?? '-',
    role: StaffRole.parse(json['role'] as String?),
  );

  final String id;
  final String name;
  final String email;

  // null kalau role di luar kasir / mitra
  final StaffRole? role;
}
