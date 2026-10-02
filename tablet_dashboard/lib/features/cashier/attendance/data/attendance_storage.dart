import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';

// Absensi disimpan di tablet per toko per hari, karena backend belum
// punya endpoint absensi
class AttendanceStorage {
  const AttendanceStorage();

  static String _key(String storeId, DateTime day) =>
      'attendance_${storeId}_${DateFormatId.compact(day)}';

  // Membaca absensi satu hari, key = id capster
  Future<Map<String, AttendanceEntry>> read(
    String storeId,
    DateTime day,
  ) async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _key(storeId, day),
    );
    if (raw == null) return {};
    final json = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return {
      for (final entry in json.entries)
        if (entry.value is Map)
          entry.key: AttendanceEntry.fromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
    };
  }

  // Menyimpan absensi satu hari
  Future<void> write(
    String storeId,
    DateTime day,
    Map<String, AttendanceEntry> entries,
  ) async {
    await (await SharedPreferences.getInstance()).setString(
      _key(storeId, day),
      jsonEncode({
        for (final entry in entries.entries) entry.key: entry.value.toJson(),
      }),
    );
  }
}
