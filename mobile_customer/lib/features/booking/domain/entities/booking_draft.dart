import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';

/// Slot yang sedang dikunci untuk user ini. Disimpan di perangkat supaya
/// booking bisa dilanjutkan setelah aplikasi ditutup, selama kuncinya belum
/// habis.
class BookingLock {
  const BookingLock({
    required this.store,
    required this.capster,
    required this.slotTime,
    required this.day,
    required this.expiresAt,
  });

  final StoreSummary store;
  final SlotCapster capster;
  final String slotTime;
  final DateTime day;
  final DateTime expiresAt;
}

/// Progres booking yang tersimpan di perangkat.
class BookingDraft {
  const BookingDraft({required this.termsAgreed, this.lock});

  final bool termsAgreed;

  /// null kalau tidak ada slot terkunci atau kuncinya sudah habis.
  final BookingLock? lock;
}
