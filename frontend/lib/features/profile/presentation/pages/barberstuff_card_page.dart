import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

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

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.cardPageTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: MemberCard(profile: args.profile),
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.profile});

  static const double _radius = 20;
  static const double _avatar = 54;

  final CustomerProfile profile;

  static String cardNumber(String id) {
    final String clean = id.replaceAll('-', '').toUpperCase();
    if (clean.isEmpty) return '#—';
    return '#${clean.substring(0, clean.length < 8 ? clean.length : 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.ink,
          borderRadius: BorderRadius.circular(_radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -18,
              top: -6,
              bottom: -6,
              child: Opacity(
                opacity: 0.07,
                child: Image.asset(
                  AppAssets.vectorCard,
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _CardAvatar(photoUrl: profile.imageUrl, size: _avatar),
                      const SizedBox(width: 14),
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
                                color: AppColor.inkFaint,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.titleMedium.copyWith(
                                color: AppColor.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    l10n.cardIdLabel,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColor.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      cardNumber(profile.id),
                      maxLines: 1,
                      style: AppTextStyle.headlineLarge.copyWith(
                        color: AppColor.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
