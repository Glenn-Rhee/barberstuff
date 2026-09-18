import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BarberstuffCardArgs {
  const BarberstuffCardArgs({required this.profile});

  final CustomerProfile profile;
}

class BarberstuffCardPage extends StatelessWidget {
  const BarberstuffCardPage({super.key, required this.args});

  final BarberstuffCardArgs args;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Profil hidup dari provider, args cuma nilai awal, supaya tarik-ulang
    // benar-benar memperbarui poin dan tier di kartu.
    final ProfileProvider profileProvider = context.watch<ProfileProvider>();
    final CustomerProfile profile = profileProvider.profile ?? args.profile;

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Image.asset(
            AppAssets.backArrowIcon,
            width: 20,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.ink,
            filterQuality: FilterQuality.medium,
          ),
        ),
        title: Text(
          l10n.cardPageTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: profileProvider.load,
          color: AppColor.goldDeep,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: MemberCard(profile: profile),
          ),
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.profile});

  static const double _radius = 16;
  static const double _avatar = 56;
  static const double _qr = 74;

  final CustomerProfile profile;

  static String cardNumber(String id) {
    final String clean = id.replaceAll(RegExp('[^0-9a-fA-F]'), '');
    if (clean.isEmpty) return '#00000000';

    int hash = 0;
    for (final int unit in clean.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }

    return '#${(hash % 100000000).toString().padLeft(8, '0')}';
  }

  static String qrPayload(String id) => 'cs$id';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TierTheme theme = TierTheme.of(profile.tier);

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: theme.gradient,
          borderRadius: BorderRadius.circular(_radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -24,
              top: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  AppAssets.vectorCard,
                  fit: BoxFit.fitHeight,
                  color: theme.sheen,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _CardAvatar(photoUrl: profile.imageUrl, size: _avatar),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              tierLabel(profile.tier, l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.bodySmall.copyWith(
                                fontSize: 12,
                                color: theme.onCard.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.titleMedium.copyWith(
                                fontSize: 17,
                                color: theme.onCard,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l10n.cardIdLabel,
                              maxLines: 1,
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: theme.onCard,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                cardNumber(profile.id),
                                maxLines: 1,
                                style: AppTextStyle.headlineLarge.copyWith(
                                  color: theme.onCard,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: qrPayload(profile.id),
                        width: _qr,
                        height: _qr,
                        color: theme.onCard,
                        drawText: false,
                        errorBuilder: (BuildContext _, String _) =>
                            SizedBox.square(dimension: _qr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAvatar extends StatelessWidget {
  const _CardAvatar({required this.photoUrl, required this.size});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.surface, width: 2),
      ),
      child: ClipOval(
        child: url == null
            ? const ColoredBox(
                color: AppColor.inkSoft,
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: AppColor.surface,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    const ColoredBox(
                      color: AppColor.inkSoft,
                      child: Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: AppColor.surface,
                      ),
                    ),
              ),
      ),
    );
  }
}
