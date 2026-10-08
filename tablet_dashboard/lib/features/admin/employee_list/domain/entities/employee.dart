import 'package:tablet_dashboard/features/admin/branch_account/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/auth/login/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';

enum EmployeeRole {
  cashier('Kasir'),
  capster('Capster'),
  mitra('Mitra');

  const EmployeeRole(this.label);

  final String label;

  StaffRole? get staffRole => switch (this) {
    cashier => StaffRole.cashier,
    mitra => StaffRole.mitra,
    capster => null,
  };
}

// Karyawan cabang: capster (GET /capster) atau akun kasir / mitra
// (GET /staff). Backend belum punya no HP, jenis kelamin, dll
class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.branch,
    this.photoUrl,
    this.email,
    this.rating = 0,
    this.active = true,
  });

  factory Employee.fromCapster(Capster capster, Branch branch) => Employee(
    id: capster.id,
    name: capster.name,
    role: EmployeeRole.capster,
    branch: branch,
    photoUrl: capster.photoUrl,
    rating: capster.rating,
    active: capster.active,
  );

  // Akun belum punya status di backend, akun yang ada bisa login
  factory Employee.fromAccount(StaffAccount account, Branch branch) => Employee(
    id: account.id,
    name: account.name,
    role: account.role == StaffRole.mitra
        ? EmployeeRole.mitra
        : EmployeeRole.cashier,
    branch: branch,
    email: account.email,
  );

  final String id;
  final String name;
  final EmployeeRole role;
  final Branch branch;
  final String? photoUrl;

  // Khusus kasir / mitra
  final String? email;

  // Khusus capster
  final double rating;
  final bool active;

  bool get isCapster => role == EmployeeRole.capster;
}
