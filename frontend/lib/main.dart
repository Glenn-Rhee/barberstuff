import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/app/app.dart';
import 'package:mobile_barberstuff/core/debug/debug_overrides.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/core/services/image_picker_service.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';
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

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<LocalController>.value(value: localController),
        ChangeNotifierProvider<DebugOverrides>(create: (_) => DebugOverrides()),
        ChangeNotifierProvider<BookingCatalog>(create: (_) => BookingCatalog()),
        Provider<AppSession>.value(value: session),
        Provider<DioClient>(create: (_) => DioClient(session: session)),
        Provider<GoogleAuthService>(create: (_) => GoogleAuthService()),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
        Provider<AuthRepository>(
          create: (BuildContext ctx) =>
              AuthRepository(AuthRemoteDataSource(ctx.read<DioClient>().dio)),
        ),
        Provider<ProfileRepository>(
          create: (BuildContext ctx) => ProfileRepository(
            ProfileRemoteDataSource(ctx.read<DioClient>().dio),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
