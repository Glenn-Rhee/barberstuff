import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/data/attendance_storage.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';

// Absensi capster hari ini di toko yang sedang dipakai
class AttendanceController extends ChangeNotifier {
  AttendanceController([this._storage = const AttendanceStorage()]);

  final AttendanceStorage _storage;

  String storeId = '';
  DateTime day = DateTime.now();
  Map<String, AttendanceEntry> entries = const {};

  Future<void> load(String storeId) async {
    this.storeId = storeId;
    day = DateTime.now();
    entries = storeId.isEmpty ? const {} : await _storage.read(storeId, day);
    notifyListeners();
  }

  // null = belum absen
  AttendanceEntry? entryOf(String capsterId) => entries[capsterId];

  bool isAbsent(String capsterId) =>
      entries[capsterId]?.status == AttendanceStatus.absent;

  AttendanceSummary summaryOf(List<Capster> capsters) {
    var present = 0, absent = 0;
    for (final capster in capsters) {
      switch (entries[capster.id]?.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case null:
          break;
      }
    }
    return AttendanceSummary(
      present: present,
      absent: absent,
      pending: capsters.length - present - absent,
    );
  }

  Future<void> mark(String capsterId, AttendanceStatus status) =>
      markAll([capsterId], status);

  Future<void> markAll(
    Iterable<String> capsterIds,
    AttendanceStatus status,
  ) async {
    if (storeId.isEmpty) return;
    // Ganti hari selagi aplikasi terbuka, mulai absensi baru
    if (!DateFormatId.isSameDay(day, DateTime.now())) await load(storeId);
    final now = DateTime.now();
    entries = {
      ...entries,
      for (final id in capsterIds) id: AttendanceEntry(status: status, at: now),
    };
    notifyListeners();
    await _storage.write(storeId, day, entries);
  }
}
