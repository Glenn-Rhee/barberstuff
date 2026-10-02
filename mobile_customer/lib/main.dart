import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/app/app.dart';
import 'package:mobile_barberstuff/app/app_providers.dart';
import 'package:mobile_barberstuff/core/localization/locale_controller.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:provider/provider.dart';

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

  final localeController = LocaleController();
  await localeController.load();

  final session = AppSession();
  await session.load();

  final cache = await AppCache.load();

  final notificationService = LocalNotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: appProviders(
        localeController: localeController,
        session: session,
        cache: cache,
        notificationService: notificationService,
      ),
      child: const App(),
    ),
  );
}
