import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';

// Isi form Tambah Cabang. Foto diunggah terpisah saat simpan
class BranchDraft {
  const BranchDraft({
    required this.name,
    required this.phone,
    required this.address,
    required this.openHour,
    required this.closeHour,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.timezone,
    this.description,
  });

  final String name;
  final String phone;
  final String address;

  // Format "09:00"
  final String openHour;
  final String closeHour;

  final double latitude;
  final double longitude;
  final BranchType type;
  final BranchTimezone timezone;
  final String? description;
}
