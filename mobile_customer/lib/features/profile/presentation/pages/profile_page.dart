import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/core/utils/phone_formatter.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/barberstuff_card_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/help_center_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/personal_info_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/dashboard_bottom_nav.dart';
import 'package:mobile_barberstuff/shared/widgets/error_retry_view.dart';
import 'package:mobile_barberstuff/shared/widgets/offline_banner.dart';
import 'package:mobile_barberstuff/shared/widgets/skeleton.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const double _sidePadding = 20;

  Future<void> _confirmLogout(BuildContext context) async {
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

    if (confirmed != true || !context.mounted) return;

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
              bottom: 28 + DashboardBottomNav.spaceOf(context),
            ),
            children: <Widget>[
              Center(child: _ProfileAvatar(photoUrl: profile.imageUrl)),
              const SizedBox(height: 18),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                style: AppTextStyle.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.email,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.inkSoft,
                ),
              ),
              if (profile.phoneNumber.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  PhoneFormatter.display(profile.phoneNumber),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColor.inkSoft,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(child: _TierBadge(tier: profile.tier)),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  static const double _size = 116;

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.ink, width: 3),
      ),
      child: ClipOval(
        child: url == null
            ? const ColoredBox(
                color: AppColor.border,
                child: Icon(
                  Icons.person_rounded,
                  size: 58,
                  color: AppColor.surface,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    const ColoredBox(
                      color: AppColor.border,
                      child: Icon(
                        Icons.person_rounded,
                        size: 58,
                        color: AppColor.surface,
                      ),
                    ),
              ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final MemberTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      decoration: BoxDecoration(
        color: TierTheme.of(tier).accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tierLabel(tier, AppLocalizations.of(context)),
        style: AppTextStyle.titleSmall.copyWith(
          color: TierTheme.of(tier).onAccent,
          letterSpacing: 0.6,
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
    if (provider.isFirstLoad) return const _ProfileSkeleton();

    final AppLocalizations l10n = AppLocalizations.of(context);

    return ErrorRetryView(
      message: provider.error?.message(l10n) ?? l10n.exceptionDefault,
      onRetry: provider.load,
    );
  }
}

/// Kerangka halaman profil: foto bulat, nama, tier, lalu daftar menu.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          ProfilePage._sidePadding,
          24,
          ProfilePage._sidePadding,
          28 + DashboardBottomNav.spaceOf(context),
        ),
        children: <Widget>[
          const Center(child: SkeletonBox.circle(size: 96)),
          const SizedBox(height: 18),
          const Center(child: SkeletonBox(width: 170, height: 20)),
          const SizedBox(height: 10),
          const Center(child: SkeletonBox(width: 210, height: 13)),
          const SizedBox(height: 8),
          const Center(child: SkeletonBox(width: 150, height: 13)),
          const SizedBox(height: 18),
          const Center(child: SkeletonBox(width: 240, height: 44, radius: 22)),
          const SizedBox(height: 26),
          for (int i = 0; i < 7; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const SkeletonBox(width: 44, height: 44, radius: 12),
                const SizedBox(width: 14),
                SkeletonBox(width: 120 + (i % 3) * 40, height: 15),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
