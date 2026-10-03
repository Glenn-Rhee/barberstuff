import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/features/cashier/store/domain/entities/store_info.dart';

// Info toko cabang. Akses backend beda per role:
// admin boleh GET /store, mitra boleh GET /store/{id}, kasir dua-duanya ditolak
class StoreApi {
  const StoreApi(this._client);

  final ApiClient _client;

  // Semua cabang, khusus admin
  Future<List<StoreInfo>> stores() async {
    final res = await _client.get(
      '/store/',
      query: {'limit': 50, 'sort_by': 'name'},
    );
    return [for (final json in res.list) StoreInfo.fromJson(json)];
  }

  // Detail satu cabang, untuk admin dan mitra
  Future<StoreInfo> store(String id) async =>
      StoreInfo.fromJson((await _client.get('/store/$id')).map);

  // Untuk kasir: nama + jam toko ikut di riwayat kas bulan ini
  // Riwayat cuma berisi shift yang sudah ditutup per bulan, jadi kalau bulan
  // ini belum ada, cari mundur sampai 3 bulan ke belakang
  Future<StoreInfo?> storeFromCashHistory() async {
    final now = DateTime.now();
    for (var back = 0; back < 3; back++) {
      final month = DateTime.utc(now.year, now.month - back, 15);
      final res = await _client.get(
        '/cash-sessions/history',
        query: {'limit': 1, 'date': month.toIso8601String()},
      );
      final store = res.list.firstOrNull?['store'];
      if (store is Map) return StoreInfo.fromJson(store.cast());
    }
    return null;
  }

  // Untuk kasir: jam buka dari slot booking hari ini.
  // Slot dibuat tiap 30 menit dari jam buka sampai sebelum jam tutup
  Future<({String open, String close})?> hoursFromSlots(
    String storeId,
    DateTime date,
  ) async {
    final res = await _client.get(
      '/booking/store',
      query: {'id_store': storeId, 'date': date.toUtc().toIso8601String()},
    );
    final slots = [
      for (final slot in (res.map['slots'] as List? ?? const []))
        if (slot is Map && slot['time'] is String) slot['time'] as String,
    ];
    if (slots.isEmpty) return null;
    final last = slots.last.split(':');
    final close = DateTime(
      2000,
      1,
      1,
      int.parse(last[0]),
      int.parse(last[1]),
    ).add(const Duration(minutes: 30));
    final closeText =
        '${close.hour.toString().padLeft(2, '0')}:${close.minute.toString().padLeft(2, '0')}';
    return (open: slots.first, close: closeText);
  }
}
