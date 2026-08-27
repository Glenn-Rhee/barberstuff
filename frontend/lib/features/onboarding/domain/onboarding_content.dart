import '../../../src/core/constants/app_assets.dart';

class OnboardingContent {
  const OnboardingContent({
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });

  final String image;
  final String title;
  final String highlight;
  final String description;

  static const String _placeholderBody =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit '
      'sed do eiusmod tempor incidunt ut labore et dolore magna aliqua.';

  static const List<OnboardingContent> items = <OnboardingContent>[
    OnboardingContent(
      image: AppAssets.onboardingFirst,
      title: 'Style that fit your daily',
      highlight: 'Lifestyle',
      description: _placeholderBody,
    ),
    OnboardingContent(
      image: AppAssets.onboardingSecond,
      title: 'hai iqbal woiiii',
      highlight: 'Lifestyle',
      description: _placeholderBody,
    ),
    OnboardingContent(
      image: AppAssets.onboardingThird,
      title: 'Style that fit your daily',
      highlight: 'Lifestyle',
      description: _placeholderBody,
    ),
  ];
}
