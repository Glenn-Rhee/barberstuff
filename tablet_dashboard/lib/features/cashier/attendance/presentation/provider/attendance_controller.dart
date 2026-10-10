import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/data/attendance_storage.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';

<<<<<<< HEAD
// Absensi capster hari ini di toko yang sedang dipakai, dikunci lewat
// status capster di server (PATCH /capster):
// - Buka shift (tiap pagi): yang belum absen dinonaktifkan
// - Hadir: diaktifkan, baru bisa dipilih di aplikasi pelanggan
// - Tidak Hadir: tetap / jadi nonaktif
// Catatan di tablet (per hari) untuk jam absen dan membedakan Belum Absen
// dengan Tidak Hadir (keduanya nonaktif di server)
=======
// Absensi capster hari ini, dikunci lewat status capster di server:
// buka shift = belum absen nonaktif, Hadir = aktif, Tidak Hadir = nonaktif
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
class AttendanceController extends ChangeNotifier {
  AttendanceController(
    this._catalog, [
    this._storage = const AttendanceStorage(),
  ]);

  final CatalogController _catalog;
  final AttendanceStorage _storage;

  String storeId = '';
  DateTime day = DateTime.now();
  Map<String, AttendanceEntry> entries = const {};

  // Capster yang statusnya sedang dikirim ke server
  Set<String> busyIds = const {};

  Future<void> load(String storeId) async {
    this.storeId = storeId;
    day = DateTime.now();
    entries = storeId.isEmpty ? const {} : await _storage.read(storeId, day);
    notifyListeners();
  }

  // Catatan absen hari ini di tablet, null = belum dicatat
  AttendanceEntry? entryOf(String capsterId) => entries[capsterId];

<<<<<<< HEAD
  // Status absen hari ini, null = belum absen. Hadir tapi sudah
  // dinonaktifkan lagi di server (mis. oleh admin) dianggap belum absen
=======
  // null = belum absen, termasuk Hadir yang dinonaktifkan lagi di server
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  AttendanceStatus? statusOf(Capster capster) {
    final status = entries[capster.id]?.status;
    if (status == AttendanceStatus.present && !capster.active) return null;
    return status;
  }

  // Tidak hadir di tablet saja, server menolak menonaktifkan
<<<<<<< HEAD
  // (mis. akun kasir), jadi pelanggan masih bisa memilihnya
  bool isLocalOnly(Capster capster) =>
      capster.active && entries[capster.id]?.status == AttendanceStatus.absent;

  // Belum absen tapi masih aktif di server (reset buka shift gagal /
  // belum jalan), jadi pelanggan masih bisa memilihnya
=======
  bool isLocalOnly(Capster capster) =>
      capster.active && entries[capster.id]?.status == AttendanceStatus.absent;

  // Belum absen tapi masih aktif di server (reset buka shift gagal)
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  bool isBookableWhilePending(Capster capster) =>
      capster.active && statusOf(capster) == null;

  bool isBusy(String capsterId) => busyIds.contains(capsterId);

  AttendanceSummary summaryOf(List<Capster> capsters) {
    var present = 0, absent = 0;
    for (final capster in capsters) {
      switch (statusOf(capster)) {
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

  // Balikin pesan kalau ada yang gagal / cuma tersimpan di tablet
  Future<String?> mark(Capster capster, AttendanceStatus status) =>
      markAll([capster], status);

  Future<String?> markAll(
    Iterable<Capster> capsters,
    AttendanceStatus status,
  ) async {
    if (storeId.isEmpty) return null;
    // Ganti hari selagi aplikasi terbuka, mulai absensi baru
    if (!DateFormatId.isSameDay(day, DateTime.now())) await load(storeId);

    final targets = [...capsters];
    busyIds = {...busyIds, for (final c in targets) c.id};
    notifyListeners();

    final saved = <String>[];
    final problems = <String>[];
    for (final capster in targets) {
      final problem = await _syncServer(capster, status);
      if (problem.saved) saved.add(capster.id);
      if (problem.message != null) problems.add(problem.message!);
    }

    final now = DateTime.now();
    entries = {
      ...entries,
      for (final id in saved) id: AttendanceEntry(status: status, at: now),
    };
    busyIds = {...busyIds}..removeAll(targets.map((c) => c.id));
    notifyListeners();
    await _storage.write(storeId, day, entries);
    return problems.isEmpty ? null : problems.join('\n');
  }

<<<<<<< HEAD
  // Dipanggil setelah buka shift: semua yang belum absen hari ini
  // dinonaktifkan, jadi belum bisa dipilih pelanggan sampai ditandai Hadir.
  // Yang sudah diabsen sebelum buka shift tidak diubah
=======
  // Setelah buka shift: capster yang belum absen dinonaktifkan
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Future<String?> resetForShift(List<Capster> capsters) async {
    if (storeId.isEmpty) return null;
    if (!DateFormatId.isSameDay(day, DateTime.now())) await load(storeId);

    final targets = [
      for (final capster in capsters)
        if (capster.active && entries[capster.id] == null) capster,
    ];
    if (targets.isEmpty) return null;
    busyIds = {...busyIds, for (final c in targets) c.id};
    notifyListeners();

    String? problem;
    for (final capster in targets) {
      try {
        await _catalog.setCapsterActive(capster, false);
      } on ApiException catch (e) {
        problem = _reasonOf(e);
        // Kalau ditolak karena akses, capster lain pasti ditolak juga
        if (e.isUnauthorized) break;
      }
    }

    busyIds = {...busyIds}..removeAll(targets.map((c) => c.id));
    notifyListeners();
<<<<<<< HEAD
    return problem == null
        ? null
        : 'Absensi belum direset, capster yang belum absen masih bisa '
              'dipilih pelanggan. $problem';
=======
    return problem == null ? null : 'Absensi belum direset. $problem';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  }

  static String _reasonOf(ApiException e) => e.isUnauthorized
      ? 'Server hanya mengizinkan admin mengubah status capster.'
      : e.message;

<<<<<<< HEAD
  // Samakan status server dengan absen. Hadir yang gagal tidak disimpan
  // (capster nonaktif tetap tidak bisa dipesan), Tidak Hadir yang gagal
  // tetap disimpan di tablet supaya tidak bisa dipilih di Kasir
=======
  // Sinkron ke server. Hadir gagal = batal, Tidak Hadir gagal = tetap di tablet
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Future<({bool saved, String? message})> _syncServer(
    Capster capster,
    AttendanceStatus status,
  ) async {
    final active = status == AttendanceStatus.present;
    if (capster.active == active) return (saved: true, message: null);
    try {
      await _catalog.setCapsterActive(capster, active);
      return (saved: true, message: null);
    } on ApiException catch (e) {
      final reason = _reasonOf(e);
      return active
          ? (
              saved: false,
              message: 'Gagal mengaktifkan ${capster.name}. $reason',
            )
          : (
              saved: true,
<<<<<<< HEAD
              message:
                  '${capster.name} tidak hadir di tablet ini saja, pelanggan '
                  'masih bisa memilihnya. $reason',
=======
              message: '${capster.name} masih bisa dipilih pelanggan. $reason',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
            );
    }
  }
}
