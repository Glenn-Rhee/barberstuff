import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/booking_injection.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/create_booking.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_store_slots.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/lock_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/release_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_lock.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_terms.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';
import 'package:mobile_barberstuff/features/store/store_injection.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'fake_booking_repository.dart';
import 'fake_store_repository.dart';

/// Semua yang dibaca halaman booking: repository palsu + use case asli.
List<SingleChildWidget> bookingTestProviders(
  AppCache cache, {
  StoreRepository? stores,
  BookingRepository? booking,
}) {
  return <SingleChildWidget>[
    Provider<AppCache>.value(value: cache),
    ChangeNotifierProvider<DebugOverrides>(create: (_) => DebugOverrides()),
    Provider<LocationService>.value(value: LocationService(cache)),
    Provider<StoreRepository>.value(value: stores ?? FakeStoreRepository()),
    ...storeUseCases(),
    Provider<BookingRepository>.value(
      value: booking ?? FakeBookingRepository(cache),
    ),
    ...bookingUseCases(),
  ];
}

/// Provider alur booking tanpa widget, untuk tes logika langkah.
BookingFlowProvider fakeBookingFlow(AppCache cache, {StoreSummary? store}) {
  final StoreRepository stores = FakeStoreRepository();
  final BookingRepository booking = FakeBookingRepository(cache);

  return BookingFlowProvider(
    getStores: GetStores(stores),
    getServices: GetStoreServices(stores),
    getSlots: GetStoreSlots(booking),
    lockSlot: LockBookingSlot(booking),
    releaseSlot: ReleaseBookingSlot(booking),
    createBooking: CreateBooking(booking),
    getDraft: GetBookingDraft(booking),
    saveTerms: SaveBookingTerms(booking),
    saveLock: SaveBookingLock(booking),
    store: store,
  );
}
