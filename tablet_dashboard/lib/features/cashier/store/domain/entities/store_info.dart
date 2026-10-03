import 'package:tablet_dashboard/core/utils/date_format.dart';

// Toko cabang yang sedang dipakai di tablet
class StoreInfo {
  const StoreInfo({
    required this.id,
    this.name,
    this.openHour,
    this.closeHour,
    this.active = true,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
    id: json['id'] as String? ?? '',
    name: json['name'] as String?,
    openHour: DateFormatId.clockOf(json['open_hour']),
    closeHour: DateFormatId.clockOf(json['close_hour']),
    active: (json['status'] as String? ?? 'open') == 'open',
  );

  final String id;

  // null kalau backend belum kasih nama (kasir belum pernah buka shift)
  final String? name;

  // Format "09:00"
  final String? openHour;
  final String? closeHour;

  // Status toko dari admin (open / close)
  final bool active;

  String get displayName => name ?? 'Toko Anda';

  // "09:00 - 17:00", null kalau jam belum diketahui
  String? get hours =>
      openHour == null || closeHour == null ? null : '$openHour - $closeHour';

  // Toko buka = status aktif dan sekarang masih di jam operasional
  bool isOpenAt(DateTime now) {
    if (!active) return false;
    final open = openHour, close = closeHour;
    if (open == null || close == null) return true;
    final minute = now.hour * 60 + now.minute;
    return minute >= DateFormatId.minutesOf(open) &&
        minute < DateFormatId.minutesOf(close);
  }

  StoreInfo copyWith({String? name, String? openHour, String? closeHour}) =>
      StoreInfo(
        id: id,
        name: name ?? this.name,
        openHour: openHour ?? this.openHour,
        closeHour: closeHour ?? this.closeHour,
        active: active,
      );
}
