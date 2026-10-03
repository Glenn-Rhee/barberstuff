import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';

abstract interface class BookingRepository {
  Future<StoreSlots> getStoreSlots({
    required String idStore,
    required DateTime date,
  });

  /// Menahan slot supaya tidak diambil orang lain selama user memilih layanan.
  Future<void> lockBooking({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  });

  Future<void> releaseLock({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  });

  /// Membuat booking lalu mencatatnya di jurnal perangkat, karena daftar
  /// booking dari server tidak mengirim kode QR dan biaya layanan.
  Future<BookingRecord> createBooking({
    required String idStore,
    required String idCapster,
    required String capsterName,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  });

  /// Booking yang baru saja dibuat dari perangkat ini.
  Stream<BookingRecord> get createdBookings;

  BookingDraft readDraft();

  Future<void> saveTermsAgreed(bool value);

  /// null menghapus kunci yang tersimpan.
  Future<void> saveLock(BookingLock? lock);
}
