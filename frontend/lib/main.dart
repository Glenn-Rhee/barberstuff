import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/app/app.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        Provider<AppSession>.value(value: session),
        Provider<DioClient>(create: (_) => DioClient()),
        Provider<AuthRepository>(
          create: (BuildContext ctx) => AuthRepository(
            AuthRemoteDataSource(ctx.read<DioClient>().dio),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
