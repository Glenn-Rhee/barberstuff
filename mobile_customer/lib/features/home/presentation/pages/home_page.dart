import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_body.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_header.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_skeleton.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/dialogs/permission_prompt.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/error_retry_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onProfileTap, this.onHistoryTap});

  final VoidCallback? onProfileTap;
  final VoidCallback? onHistoryTap;

  /// Jarak gulir sebelum header ciut. Terbukanya baru di puncak (offset 0);
  /// selisih ini mencegah header berkedip saat jari berhenti dekat puncak.
  static const double collapseThreshold = 12;

  /// Header ciut begitu halaman digulir turun, lalu baru terbuka lagi setelah
  /// benar-benar kembali ke puncak. Dulu ikut arah gulir, jadi header muncul
  /// setiap kali jari membalik arah atau berhenti di tengah halaman.
  static bool headerCollapsed({
    required bool wasCollapsed,
    required double offset,
  }) {
    return wasCollapsed ? offset > 0 : offset > collapseThreshold;
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scroll = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _askPermissions();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;

    final bool next = HomePage.headerCollapsed(
      wasCollapsed: _collapsed,
      offset: _scroll.offset,
    );
    if (next != _collapsed) setState(() => _collapsed = next);
  }

  Future<void> _askPermissions() async {
    if (!mounted) return;
    await PermissionPrompt.askNotification(context);
    if (!mounted) return;
    await PermissionPrompt.askLocation(context);
    if (!mounted) return;

    await context.read<DashboardProvider>().refreshLocation();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider p = context.watch<ProfileProvider>();
    final CustomerProfile? profile = p.profile;

    return Column(
      children: <Widget>[
        DashboardHeader(
          name: profile?.name ?? '',
          photoUrl: profile?.imageUrl,
          collapsed: _collapsed,
          onNotificationTap: () {
            Navigator.of(context).pushNamed(AppRoute.notification);
          },
          onProfileTap: widget.onProfileTap ?? () {},
        ),
        Expanded(
          child: ColoredBox(
            color: AppColor.surface,
            child: profile == null
                ? _PlaceholderBody(provider: p)
                : DashboardBody(
                    profile: profile,
                    onRefresh: p.load,
                    controller: _scroll,
                    onHistoryTap: widget.onHistoryTap,
                  ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isFirstLoad) return const DashboardSkeleton();

    final AppLocalizations l10n = AppLocalizations.of(context);

    return ErrorRetryView(
      message: provider.error?.message(l10n) ?? l10n.exceptionDefault,
      onRetry: provider.load,
    );
  }
}
