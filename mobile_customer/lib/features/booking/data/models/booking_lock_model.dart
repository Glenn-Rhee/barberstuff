import 'package:mobile_barberstuff/features/booking/data/models/booking_slot_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';

class BookingLockModel extends BookingLock {
  const BookingLockModel({
    required super.store,
    required super.capster,
    required super.slotTime,
    required super.day,
    required super.expiresAt,
  });

  factory BookingLockModel.fromEntity(BookingLock lock) {
    return BookingLockModel(
      store: lock.store,
      capster: lock.capster,
      slotTime: lock.slotTime,
      day: lock.day,
      expiresAt: lock.expiresAt,
    );
  }

  /// Dibaca terpisah supaya kunci yang sudah habis bisa dibuang tanpa
  /// perlu memeriksa isi lainnya.
  static DateTime expiresAtOf(Map<String, dynamic> json) {
    final int millis = (json['expires_at'] as num?)?.toInt() ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// null kalau isinya rusak, misalnya dari versi aplikasi lama.
  static BookingLockModel? fromJson(Map<String, dynamic> json) {
    final Object? store = json['store'];
    final Object? capster = json['capster'];
    if (store is! Map<String, dynamic> || capster is! Map<String, dynamic>) {
      return null;
    }

    return BookingLockModel(
      store: StoreSummaryModel.fromJson(store),
      capster: SlotCapsterModel.fromJson(capster),
      slotTime: '${json['slot_time']}',
      day: DateTime.tryParse('${json['day']}') ?? DateTime.now(),
      expiresAt: expiresAtOf(json),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'store': StoreSummaryModel.fromEntity(store).toJson(),
    'capster': SlotCapsterModel.fromEntity(capster).toJson(),
    'slot_time': slotTime,
    'day': day.toIso8601String(),
    'expires_at': expiresAt.millisecondsSinceEpoch,
  };
}
