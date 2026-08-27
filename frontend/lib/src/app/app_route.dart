import 'package:flutter/material.dart';

// import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_brand_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/transitions/circular_reveal_route.dart';

class AppRoute {
  const AppRoute._();

  static const String splash = '/';
  static const String splashBrand = '/splash-brand';
  // static const String onboarding = '/onboarding';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const SplashPage(),
        );
      case splashBrand:
        return CircularRevealRoute<void>(
          settings: settings,
          builder: (BuildContext context) => SplashBrandPage(
            // onFinished: () =>
            //     Navigator.of(context).pushReplacementNamed(onboarding),
          ),
        );
      // case onboarding:
      //   return MaterialPageRoute<void>(
      //     settings: settings,
      //     builder: (BuildContext context) => const OnboardingPage(),
      //   );
      
      default:
        return null;
    }
  }
}
