import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/watch_created_bookings.dart';
import 'package:mobile_barberstuff/features/history/data/datasources/history_remote_datasource.dart';
import 'package:mobile_barberstuff/features/history/data/repositories/history_repository_impl.dart';
import 'package:mobile_barberstuff/features/history/domain/repositories/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/get_booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/submit_booking_review.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur riwayat. Dipasang sesudah fitur booking, karena riwayat
/// memakai jurnal booking perangkat dan aliran booking baru.
List<SingleChildWidget> historyProviders() => <SingleChildWidget>[
  Provider<HistoryRemoteDataSource>(
    create: (ctx) => HistoryRemoteDataSource(ctx.read<DioClient>().dio),
  ),
  Provider<HistoryRepository>(
    create: (ctx) => HistoryRepositoryImpl(
      ctx.read<HistoryRemoteDataSource>(),
      ctx.read<BookingLocalDataSource>(),
    ),
  ),
  Provider<GetBookingHistory>(
    create: (ctx) => GetBookingHistory(ctx.read<HistoryRepository>()),
  ),
  Provider<SubmitBookingReview>(
    create: (ctx) => SubmitBookingReview(ctx.read<HistoryRepository>()),
  ),
  ChangeNotifierProvider<CustomerBookingsProvider>(
    create: (ctx) => CustomerBookingsProvider(
      ctx.read<GetBookingHistory>(),
      ctx.read<SubmitBookingReview>(),
      createdBookings: ctx.read<WatchCreatedBookings>()(const NoParams()),
    ),
  ),
];
