import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/create_booking.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_store_slots.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/lock_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/release_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_lock.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_terms.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/watch_created_bookings.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur booking: datasource → repository → use case.
/// Butuh [DioClient] dan [AppCache] sudah terpasang di atasnya.
List<SingleChildWidget> bookingProviders() => <SingleChildWidget>[
  Provider<BookingRemoteDataSource>(
    create: (ctx) => BookingRemoteDataSource(ctx.read<DioClient>().dio),
  ),
  Provider<BookingLocalDataSource>(
    create: (ctx) => BookingLocalDataSource(ctx.read<AppCache>()),
  ),
  Provider<BookingRepository>(
    create: (ctx) => BookingRepositoryImpl(
      ctx.read<BookingRemoteDataSource>(),
      ctx.read<BookingLocalDataSource>(),
    ),
  ),
  ...bookingUseCases(),
];

/// Use case saja, supaya tes bisa memasang [BookingRepository] palsu.
List<SingleChildWidget> bookingUseCases() => <SingleChildWidget>[
  Provider<GetStoreSlots>(
    create: (ctx) => GetStoreSlots(ctx.read<BookingRepository>()),
  ),
  Provider<LockBookingSlot>(
    create: (ctx) => LockBookingSlot(ctx.read<BookingRepository>()),
  ),
  Provider<ReleaseBookingSlot>(
    create: (ctx) => ReleaseBookingSlot(ctx.read<BookingRepository>()),
  ),
  Provider<CreateBooking>(
    create: (ctx) => CreateBooking(ctx.read<BookingRepository>()),
  ),
  Provider<GetBookingDraft>(
    create: (ctx) => GetBookingDraft(ctx.read<BookingRepository>()),
  ),
  Provider<SaveBookingTerms>(
    create: (ctx) => SaveBookingTerms(ctx.read<BookingRepository>()),
  ),
  Provider<SaveBookingLock>(
    create: (ctx) => SaveBookingLock(ctx.read<BookingRepository>()),
  ),
  Provider<WatchCreatedBookings>(
    create: (ctx) => WatchCreatedBookings(ctx.read<BookingRepository>()),
  ),
];
