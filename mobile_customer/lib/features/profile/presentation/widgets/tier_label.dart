import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

String tierLabel(MemberTier tier, AppLocalizations l10n) {
  switch (tier) {
    case MemberTier.silver:
      return l10n.profileTierSilver;
    case MemberTier.gold:
      return l10n.profileTierGold;
    case MemberTier.platinum:
      return l10n.profileTierPlatinum;
  }
}
