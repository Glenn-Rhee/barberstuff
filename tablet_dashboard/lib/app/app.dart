import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tablet_dashboard/app/app_env.dart';
import 'package:tablet_dashboard/app/app_provider.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_theme.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/presentation/pages/login_screen.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/customer/data/customer_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/store/data/store_api.dart';
import 'package:tablet_dashboard/features/home/presentation/pages/dashboard_screen.dart';

class TabletDashboardApp extends StatefulWidget {
  const TabletDashboardApp({
    super.key,
    this.authApi,
    this.catalogApi,
    this.bookingApi,
    this.cashSessionApi,
    this.storeApi,
    this.customerApi,
    this.branchApi,
    this.printer,
  });

  // attribut, bisa diganti fake untuk test. Default ke backend asli
  final AuthApi? authApi;
  final CatalogApi? catalogApi;
  final BookingApi? bookingApi;
  final CashSessionApi? cashSessionApi;
  final StoreApi? storeApi;
  final CustomerApi? customerApi;
  final BranchApi? branchApi;
  final PrinterController? printer;

  @override
  State<TabletDashboardApp> createState() => _TabletDashboardAppState();
}

class _TabletDashboardAppState extends State<TabletDashboardApp> {
  // Dibuat sekali, client baru tiap build() kehilangan token
  late final ApiClient _client = ApiClient(baseUrl: AppEnv.baseUrl);
  late final List<SingleChildWidget> _providers = appProviders(
    client: _client,
    authApi: widget.authApi ?? AuthApi(_client),
    catalogApi: widget.catalogApi ?? CatalogApi(_client),
    bookingApi: widget.bookingApi ?? BookingApi(_client),
    cashSessionApi: widget.cashSessionApi ?? CashSessionApi(_client),
    storeApi: widget.storeApi ?? StoreApi(_client),
    customerApi: widget.customerApi ?? CustomerApi(_client),
    branchApi: widget.branchApi ?? BranchApi(_client),
    printer: widget.printer,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      child: MaterialApp(
        title: "Dashboard Barberstuff",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Teks bawaan Material (kalender, tombol dialog) pakai Bahasa Indonesia
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
