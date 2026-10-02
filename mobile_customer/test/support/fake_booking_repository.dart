import 'package:dio/dio.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Endpoint booking diganti data contoh; progres booking (syarat dan kunci
/// slot) tetap disimpan sungguhan di [AppCache] tiruan.
class FakeBookingRepository extends BookingRepositoryImpl {
  FakeBookingRepository(AppCache cache)
    : super(BookingRemoteDataSource(Dio()), BookingLocalDataSource(cache));

  static Future<AppCache> emptyCache() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return AppCache.load();
  }

  static const SlotCapster sampleCapster = SlotCapster(
    id: 'capster-1',
    name: 'Joni Akbar',
    avgRating: 4.9,
    imageUrl: '',
    available: true,
  );

  @override
  Future<StoreSlots> getStoreSlots({
    required String idStore,
    required DateTime date,
  }) async {
    return StoreSlots(
      idStore: idStore,
      date: date,
      slots: <BookingSlot>[
        const BookingSlot(
          time: '20:00',
          available: true,
          capsters: <SlotCapster>[sampleCapster],
        ),
        const BookingSlot(
          time: '21:00',
          available: false,
          capsters: <SlotCapster>[],
        ),
      ],
    );
  }

  @override
  Future<void> lockBooking({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {}

  @override
  Future<void> releaseLock({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {}

  @override
  Future<BookingRecord> createBooking({
    required String idStore,
    required String idCapster,
    required String capsterName,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  }) async {
    return BookingRecord(
      id: 'booking-1',
      qrCode: 'bkbooking-1',
      scheduledAt: bookingDate,
      createdAt: DateTime.now(),
      storeId: 'store-1',
      storeName: 'Barberstuff Kemang Raya',
      storeAddress: 'Jl. Metro Pondok Indah No. 12',
      storePhone: '081234567890',
      capsterId: idCapster,
      capsterName: capsterName,
      lines: const <BookingLine>[
        BookingLine(id: 'service-1', name: 'Cukur Rambut', price: 45000),
      ],
      appServiceFee: 2000,
      totalPrice: 45000,
    );
  }
}
