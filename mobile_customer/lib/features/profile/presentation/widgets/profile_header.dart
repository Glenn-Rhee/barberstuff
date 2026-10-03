import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/core/utils/phone_formatter.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Bagian atas halaman profil: foto, nama, email, nomor HP, lalu tier.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
        ),
        if (profile.phoneNumber.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            PhoneFormatter.display(profile.phoneNumber),
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
          ),
        ],
        const SizedBox(height: 16),
        Center(child: _TierBadge(tier: profile.tier)),
      ],
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
