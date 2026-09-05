import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      create: (BuildContext ctx) =>
          ProfileProvider(ctx.read<ProfileRepository>()),
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
    if (tab == DashboardTab.booking || tab == DashboardTab.history) {
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
        bottomNavigationBar: DashboardBottomNav(
          current: _tab,
          onSelect: _select,
        ),
      ),
    );
  }
}
