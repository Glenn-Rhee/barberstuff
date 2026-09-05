import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

String tierLabel(MemberTier tier, AppLocalizations l10n) {
  switch (tier) {
    case MemberTier.newbie:
      return l10n.profileTierNewbie;
    case MemberTier.bestie:
      return l10n.profileTierBestie;
    case MemberTier.royal:
      return l10n.profileTierRoyal;
    case MemberTier.crazy:
      return l10n.profileTierCrazy;
  }
}
