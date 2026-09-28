import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/deeplink/store_link.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/debug/presentation/widgets/debug_panel.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/history/presentation/pages/history_page.dart';
import 'package:mobile_barberstuff/features/home/presentation/pages/home_page.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DebugShellPage extends StatelessWidget {
  const DebugShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<DashboardProvider>(
          create: (BuildContext ctx) => DashboardProvider(
            ctx.read<BookingRepository>(),
            ctx.read<HistoryRepository>(),
            ctx.read<LocationService>(),
          ),
        ),
      ],
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

  @override
  void initState() {
    super.initState();
    // Tautan cabang yang datang sebelum user sampai beranda (aplikasi baru
    // dibuka dari tautan, atau user login dulu) dibuka di sini.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) return;
      // Beranda adalah pintu masuk setelah login mana pun (sandi, Google,
      // lengkapi profil), jadi profil dipastikan dimuat di sini.
      context.read<ProfileProvider>().ensureLoaded();

      final String? storeId = StoreLink.take();
      if (storeId == null) return;

      Navigator.of(context).pushNamed(
        AppRoute.storeDetail,
        arguments: StoreDetailArgs(storeId: storeId),
      );
    });
  }

  void _select(DashboardTab tab) {
    if (tab == DashboardTab.booking) {
      Navigator.of(context).pushNamed(AppRoute.booking);
      return;
    }
    if (tab != _tab) setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final bool onHome = _tab == DashboardTab.home;
    const List<DashboardTab> stacked = <DashboardTab>[
      DashboardTab.home,
      DashboardTab.history,
      DashboardTab.profile,
    ];
    final int index = stacked.indexOf(_tab).clamp(0, stacked.length - 1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: onHome ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        // Area status bar sudah dicat hitam oleh DashboardHeader.
        backgroundColor: AppColor.surface,
        // Konten dibiarkan memanjang ke belakang nav bawah yang tembus pandang.
        extendBody: true,
        body: IndexedStack(
          index: index,
          children: <Widget>[
            HomePage(
              onProfileTap: () => _select(DashboardTab.profile),
              onHistoryTap: () => _select(DashboardTab.history),
            ),
            const HistoryPage(),
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
