import 'package:mobile_barberstuff/l10n/app_localization.dart';

import '../../../src/core/constants/app_assets.dart';

class OnboardingContent {
  const OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;



  static List<OnboardingContent> items(AppLocalizations l10n) {
    return <OnboardingContent> [
    OnboardingContent(
      image: AppAssets.onboardingFirst,
      title: l10n.onboardingFirstTitle,
      description: l10n.onboardingFirstDescription,
    ),
    OnboardingContent(
      image: AppAssets.onboardingSecond,
      title: l10n.onboardingSecondTitle,
      description: l10n.onboardingSecondDescription,
    ),
    OnboardingContent(
      image: AppAssets.onboardingThird,
      title: l10n.onboardingThirdTitle,
      description: l10n.onboardingThirdDescription,
    ),
  ];
  } 
}
