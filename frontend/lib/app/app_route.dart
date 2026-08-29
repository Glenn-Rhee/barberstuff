import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/choose_login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_success_page.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_brand_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_page.dart';
import 'package:mobile_barberstuff/shared/transitions/circular_reveal_route.dart';

class AppRoute {
  const AppRoute._();

  static const String splash = '/';
  static const String splashBrand = '/splash-brand';
  static const String onboarding = '/onboarding';
  static const String chooseLogin = '/choose-login';
  static const String registerPage = '/register-page';
  static const String verifyOtp = '/verify-otp';
  static const String verifySuccess = '/verify-success';

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
            onFinished: () =>
                Navigator.of(context).pushReplacementNamed(onboarding),
          ),
        );
      case onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const OnboardingPage(),
        );
      case chooseLogin:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const ChooseLoginPage(),
        );
      case registerPage:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const RegisterPage(),
        );
      case verifyOtp:
        final Object? args = settings.arguments;
        if (args is! VerifyOtpArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => VerifyOtpPage(args: args),
        );
      case verifySuccess:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const VerifySuccessPage(),
        );

      default:
        return null;
    }
  }
}
