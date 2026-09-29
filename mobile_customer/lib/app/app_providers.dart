import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/core/services/image_picker_service.dart';
import 'package:mobile_barberstuff/core/services/image_upload_service.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/auth/auth_injection.dart';
import 'package:mobile_barberstuff/features/booking/booking_injection.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/booking_catalog.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/history/history_injection.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/profile/profile_injection.dart';
import 'package:mobile_barberstuff/features/promo/promo_injection.dart';
import 'package:mobile_barberstuff/features/store/store_injection.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Semua dependency aplikasi, dari yang paling dasar: service inti dulu,
/// lalu tiap fitur (datasource → repository → use case). Urutan penting:
/// fitur yang memakai fitur lain dipasang sesudahnya, misalnya riwayat
/// sesudah booking.
List<SingleChildWidget> appProviders({
  required LocalController localController,
  required AppSession session,
  required AppCache cache,
  required LocalNotificationService notificationService,
}) {
  return <SingleChildWidget>[
    ChangeNotifierProvider<LocalController>.value(value: localController),
    ChangeNotifierProvider<DebugOverrides>(create: (_) => DebugOverrides()),
    ChangeNotifierProvider<BookingCatalog>(create: (_) => BookingCatalog()),
    ChangeNotifierProvider<NotificationProvider>(
      create: (_) => NotificationProvider(),
    ),
    Provider<AppSession>.value(value: session),
    Provider<AppCache>.value(value: cache),
    Provider<LocationService>(
      create: (ctx) => LocationService(ctx.read<AppCache>()),
    ),
    Provider<LocalNotificationService>.value(value: notificationService),
    Provider<DioClient>(
      create: (ctx) => DioClient(
        session: session,
        isOffline: () => ctx.read<DebugOverrides>().forceOffline,
      ),
    ),
    Provider<GoogleAuthService>(create: (_) => GoogleAuthService()),
    Provider<ImagePickerService>(create: (_) => ImagePickerService()),
    Provider<ImageUploadService>(
      create: (ctx) => ImageUploadService(ctx.read<DioClient>().dio),
    ),
    ...authProviders(),
    ...storeProviders(),
    ...bookingProviders(),
    ...historyProviders(),
    ...profileProviders(),
    ...promoProviders(),
  ];
}
