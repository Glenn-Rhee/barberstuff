import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/choose_login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_success_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/forgot_password_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/reset_password_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/reset_success_page.dart';
import 'package:mobile_barberstuff/features/main/presentation/pages/main_shell_page.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_brand_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_page.dart';
import 'package:mobile_barberstuff/shared/transitions/circular_reveal_route.dart';
import 'package:provider/provider.dart';

class AppRoute {
  const AppRoute._();

  static const String splash = '/';
  static const String splashBrand = '/splash-brand';
  static const String onboarding = '/onboarding';
  static const String chooseLogin = '/choose-login';
  static const String registerPage = '/register-page';
  static const String login = '/login';
  static const String home = '/home';
  static const String verifyOtp = '/verify-otp';
  static const String verifySuccess = '/verify-success';
  static const String completeProfile = '/complete-profile';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';

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
            onFinished: () => Navigator.of(context).pushReplacementNamed(
              context.read<AppSession>().hasValidSession ? home : onboarding,
            ),
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
      case completeProfile:
        final Object? args = settings.arguments;
        if (args is! CompleteProfileArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => CompleteProfilePage(args: args),
        );
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const LoginPage(),
        );
      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const MainShellPage(),
        );
      case verifySuccess:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const VerifySuccessPage(),
        );
      case forgotPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const ForgotPasswordPage(),
        );
      case resetPassword:
        final Object? args = settings.arguments;
        if (args is! ResetPasswordArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => ResetPasswordPage(args: args),
        );
      case resetSuccess:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const ResetSuccessPage(),
        );

      default:
        return null;
    }
  }
}
