import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/app_env.dart';
import 'package:tablet_dashboard/app/app_provider.dart';
import 'package:tablet_dashboard/features/home/presentation/pages/dashboard_screen.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_theme.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/auth/presentation/pages/login_screen.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';

class TabletDashboardApp extends StatelessWidget {
  const TabletDashboardApp({
    super.key,
    this.authApi,
    this.catalogApi,
    this.bookingApi,
    this.cashSessionApi,
    this.printer,
  });

  // attribut, bisa diganti fake untuk test. Default ke backend asli
  final AuthApi? authApi;
  final CatalogApi? catalogApi;
  final BookingApi? bookingApi;
  final CashSessionApi? cashSessionApi;
  final PrinterController? printer;

  @override
  Widget build(BuildContext context) {
    final client = ApiClient(baseUrl: AppEnv.baseUrl);
    return MultiProvider(
      providers: appProviders(
        client: client,
        authApi: authApi ?? AuthApi(client),
        catalogApi: catalogApi ?? CatalogApi(client),
        bookingApi: bookingApi ?? BookingApi(client),
        cashSessionApi: cashSessionApi ?? CashSessionApi(client),
        printer: printer,
      ),
      child: MaterialApp(
        title: "Dashboard Barberstuff",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Consumer<SessionController>(
          builder: (context, session, _) {
            if (session.restoring) return const _Splash();
            return session.signedIn
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.ink,
      body: Center(child: CircularProgressIndicator(color: AppColor.gold)),
    );
  }
}
