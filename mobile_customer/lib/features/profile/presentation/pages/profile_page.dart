import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/barberstuff_card_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/help_center_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/personal_info_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/profile_skeleton.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/error_retry_view.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/offline_banner.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/dashboard_bottom_nav.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const double _sidePadding = 20;

  Future<void> _confirmLogout(BuildContext context) async {
    final bool confirmed = await _askLogout(context);
    if (!confirmed || !context.mounted) return;
    await _logout(context);
  }

  /// Gaya dialog ini sedikit beda dari showConfirmDialog (judul dan tombol
  /// lebih besar), jadi sengaja dibiarkan sendiri.
  Future<bool> _askLogout(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.profileLogoutTitle, style: AppTextStyle.titleLarge),
        content: Text(
          l10n.profileLogoutMessage,
          style: AppTextStyle.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: AppTextStyle.labelLarge.copyWith(color: AppColor.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileMenuLogout,
              style: AppTextStyle.labelLarge.copyWith(color: AppColor.danger),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Hapus semua data akun ini dari memori dan perangkat, lalu kembali ke
  /// halaman pilih login.
  Future<void> _logout(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final AppCache cache = context.read<AppCache>();
    final AppSession session = context.read<AppSession>();
    context.read<ProfileProvider>().reset();
    context.read<CustomerBookingsProvider>().reset();
    // Cadangan offline milik akun ini, jangan sampai tampil di akun berikutnya.
    await cache.remove(AppCache.keyCustomerProfile);
    await session.clearSession();

    navigator.pushNamedAndRemoveUntil(
      AppRoute.chooseLogin,
      (Route<dynamic> r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider p = context.watch<ProfileProvider>();
    final CustomerProfile? profile = p.profile;
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (profile == null) {
      return ColoredBox(
        color: AppColor.surface,
        child: _PlaceholderBody(provider: p),
      );
    }

    return ColoredBox(
      color: AppColor.surface,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: p.load,
          color: AppColor.orangeLight,
          child: ListView(
            padding: EdgeInsets.only(
              top: 24,
              bottom: DashboardBottomNav.contentGap,
            ),
            children: <Widget>[
              ProfileHeader(profile: profile),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _sidePadding),
                child: Divider(height: 1, thickness: 1, color: AppColor.border),
              ),
              const SizedBox(height: 8),

              if (p.isFromCache)
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    _sidePadding,
                    0,
                    _sidePadding,
                    12,
                  ),
                  child: OfflineBanner(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
                child: ProfileMenuGroup(
                  children: <Widget>[
                    ProfileMenuTile(
                      iconPath: AppAssets.userProfile,
                      label: l10n.profileMenuPersonalInfo,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoute.personalInfo,
                        arguments: PersonalInfoArgs(profile: profile),
                      ),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.globeProfile,
                      label: l10n.profileMenuLanguage,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoute.language),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.idCardProfile,
                      label: l10n.profileMenuCard,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoute.barberstuffCard,
                        arguments: BarberstuffCardArgs(profile: profile),
                      ),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.bellProfile,
                      label: l10n.profileMenuNotification,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoute.notification),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.helpCircleProfile,
                      label: l10n.profileMenuHelp,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoute.helpCenter,
                        arguments: HelpCenterArgs(profile: profile),
                      ),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.infoProfile,
                      label: l10n.profileMenuAbout,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoute.about),
                    ),
                    ProfileMenuTile(
                      iconPath: AppAssets.logOutProfile,
                      label: l10n.profileMenuLogout,
                      danger: true,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isFirstLoad) return const ProfileSkeleton();

    final AppLocalizations l10n = AppLocalizations.of(context);

    return ErrorRetryView(
      message: provider.error?.message(l10n) ?? l10n.exceptionDefault,
      onRetry: provider.load,
    );
  }
}
