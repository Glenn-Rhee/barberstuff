import 'package:dio/dio.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository(AppCache cache)
    : super(BookingRemoteDataSource(Dio()), cache);

  static Future<AppCache> emptyCache() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return AppCache.load();
  }

  static const StoreSummary sampleStore = StoreSummary(
    id: 'store-1',
    name: 'Barberstuff Kemang Raya',
    address: 'Jl. Metro Pondok Indah No. 12',
    phoneNumber: '081234567890',
    bannerUrl: '',
    storeType: 'lite',
    status: 'open',
    avgRating: 4.8,
    totalCapster: 3,
    totalService: 5,
    totalPackage: 2,
  );

  static const SlotCapster sampleCapster = SlotCapster(
    id: 'capster-1',
    name: 'Joni Akbar',
    avgRating: 4.9,
    imageUrl: '',
    available: true,
  );

  static const ServiceItem sampleService = ServiceItem(
    id: 'service-1',
    name: 'Cukur Rambut',
    price: 45000,
    idStore: 'store-1',
    type: ProductType.service,
    status: 'active',
    description: 'Potong rambut standar, cuci rambut, dan pijat ringan.',
  );

  @override
  Future<CachedResult<List<StoreSummary>>> getStores({String? name}) async =>
      const CachedResult<List<StoreSummary>>(<StoreSummary>[
        sampleStore,
      ], fromCache: false);

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
  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  }) async => <ServiceItem>[sampleService];

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
  Future<BookingResult> createBooking({
    required String idStore,
    required String idCapster,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  }) async {
    return BookingResult(
      idBooking: 'booking-1',
      qrCode: 'bkbooking-1',
      bookingDate: bookingDate,
      appServiceFee: 2000,
      totalPrice: 45000,
      store: const BookingStoreInfo(
        id: 'store-1',
        name: 'Barberstuff Kemang Raya',
        address: 'Jl. Metro Pondok Indah No. 12',
        phoneNumber: '081234567890',
      ),
      capster: const BookingCapsterInfo(id: 'capster-1', name: 'Joni Akbar'),
      services: const <BookingServiceInfo>[
        BookingServiceInfo(id: 'service-1', name: 'Cukur Rambut', price: 45000),
      ],
    );
  }
}
