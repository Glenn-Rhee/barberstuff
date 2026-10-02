import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_theme.dart';

class TabletDashboardApp extends StatelessWidget {
  const TabletDashboardApp({
    super.key,
    // this.authApi,
    // this.catalogApi,
    // this.bookingApi,
    // this.cashSessionApi,
    // this.printer,
  });

  // attribut
  // final AuthApi? authApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dashboard Barberstuff",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<SessionController>(
        builder: (_, session, _) {
          if (session.restoring) return const _Splash();
          return session.signedIn ? const MainShellPage() : const LoginPage();
        },
      ),
    );
  }
}
