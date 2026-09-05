import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/debug/debug_overrides.dart';
import 'package:mobile_barberstuff/core/debug/debug_panel.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/home/presentation/pages/home_page.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:provider/provider.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (BuildContext ctx) => ProfileProvider(
        ctx.read<ProfileRepository>(),
        ctx.read<DebugOverrides>(),
      ),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatefulWidget {
  const _MainShellView();

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
  DashboardTab _tab = DashboardTab.home;

  void _select(DashboardTab tab) {
    if (tab == DashboardTab.booking) {
      Navigator.of(context).pushNamed(AppRoute.booking);
      return;
    }
    if (tab == DashboardTab.history) {
      showComingSoonDialog(context);
      return;
    }
    if (tab != _tab) setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final bool onHome = _tab == DashboardTab.home;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: onHome ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: onHome ? AppColor.ink : AppColor.surface,
        body: IndexedStack(
          index: onHome ? 0 : 1,
          children: <Widget>[
            HomePage(onProfileTap: () => _select(DashboardTab.profile)),
            const ProfilePage(),
          ],
        ),
        floatingActionButton: kDebugMode
            ? FloatingActionButton.small(
                heroTag: 'debug-preview',
                backgroundColor: AppColor.ink,
                foregroundColor: AppColor.surface,
                onPressed: () => showDebugPanel(context),
                child: const Icon(Icons.bug_report_rounded, size: 20),
              )
            : null,
        bottomNavigationBar: DashboardBottomNav(
          current: _tab,
          onSelect: _select,
        ),
      ),
    );
  }
}
