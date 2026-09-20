import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/app/app.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/core/services/image_picker_service.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  final localController = LocalController();
  await localController.load();

  final session = AppSession();
  await session.load();

  final cache = await AppCache.load();

  final notificationService = LocalNotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<LocalController>.value(value: localController),
        ChangeNotifierProvider<DebugOverrides>(create: (_) => DebugOverrides()),
        ChangeNotifierProvider<BookingCatalog>(create: (_) => BookingCatalog()),
        ChangeNotifierProvider<BookingJournal>(
          create: (_) => BookingJournal(cache),
        ),
        ChangeNotifierProxyProvider<BookingJournal, HistoryRepository>(
          create: (BuildContext ctx) =>
              HistoryRepository(ctx.read<BookingJournal>()),
          update: (_, BookingJournal journal, HistoryRepository? previous) =>
              previous ?? HistoryRepository(journal),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        Provider<AppSession>.value(value: session),
        Provider<AppCache>.value(value: cache),
        Provider<LocationService>(
          create: (BuildContext ctx) => LocationService(ctx.read<AppCache>()),
        ),
        Provider<LocalNotificationService>.value(value: notificationService),
        Provider<DioClient>(
          create: (BuildContext ctx) => DioClient(
            session: session,
            isOffline: () => ctx.read<DebugOverrides>().forceOffline,
          ),
        ),
        Provider<GoogleAuthService>(create: (_) => GoogleAuthService()),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
        Provider<AuthRepository>(
          create: (BuildContext ctx) =>
              AuthRepository(AuthRemoteDataSource(ctx.read<DioClient>().dio)),
        ),
        Provider<BookingRepository>(
          create: (BuildContext ctx) => BookingRepository(
            BookingRemoteDataSource(ctx.read<DioClient>().dio),
            ctx.read<AppCache>(),
          ),
        ),
        Provider<StoreRepository>(
          create: (BuildContext ctx) =>
              StoreRepository(StoreRemoteDataSource(ctx.read<DioClient>().dio)),
        ),
        Provider<ProfileRepository>(
          create: (BuildContext ctx) => ProfileRepository(
            ProfileRemoteDataSource(ctx.read<DioClient>().dio),
            ctx.read<AppCache>(),
          ),
        ),
        // Lazy: baru memuat profil saat layar pertama membacanya, bukan saat
        // aplikasi dibuka, supaya tidak menembak API sebelum login.
        ChangeNotifierProvider<ProfileProvider>(
          create: (BuildContext ctx) => ProfileProvider(
            ctx.read<ProfileRepository>(),
            ctx.read<DebugOverrides>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
