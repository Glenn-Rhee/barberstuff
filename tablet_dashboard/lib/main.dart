import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app_shell.dart';
import 'app/navigation_controller.dart';
import 'core/network/api_client.dart';
import 'core/printer/printer_controller.dart';
import 'core/theme/app_color.dart';
import 'core/theme/app_theme.dart';
import 'data/api/barberstuff_api.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/provider/session_controller.dart';
import 'features/cashier/presentation/provider/catalog_controller.dart';
import 'features/cashier/presentation/provider/order_controller.dart';
import 'features/dashboard/presentation/provider/shift_controller.dart';
import 'features/reservation/presentation/provider/bookings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The cashier tablet is landscape only and runs full screen like a POS.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TabletApp());
}

class TabletApp extends StatelessWidget {
  const TabletApp({super.key, this.api, this.printer});

  /// Injectable for tests; defaults to the live Barberstuff API.
  final BarberstuffApi? api;
  final PrinterController? printer;

  @override
  Widget build(BuildContext context) {
    final api = this.api ?? BarberstuffApi(ApiClient());

    return MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider(create: (_) => printer ?? PrinterController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => SessionController(api)..restore()),
        ChangeNotifierProvider(create: (_) => ShiftController(api)),
        ChangeNotifierProvider(create: (_) => CatalogController(api)),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => BookingsController(api)),
      ],
      child: MaterialApp(
        title: 'Dashboard Barberstuff',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Consumer<SessionController>(
          builder: (_, session, _) {
            if (session.restoring) return const _Splash();
            return session.signedIn ? const AppShell() : const LoginPage();
          },
        ),
      ),
    );
  }
}

/// Shown while the saved token is checked against the API.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.sidebar,
      body: Center(child: CircularProgressIndicator(color: AppColor.gold)),
    );
  }
}
