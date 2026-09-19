import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/deeplink/store_link.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/choose_login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_success_page.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_flow_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_receipt_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_success_page.dart';
import 'package:mobile_barberstuff/features/debug/presentation/pages/debug_shell_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/forgot_password_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/reset_password_page.dart';
import 'package:mobile_barberstuff/features/forgot_password/presentation/pages/reset_success_page.dart';
import 'package:mobile_barberstuff/features/history/presentation/pages/history_page.dart';
import 'package:mobile_barberstuff/features/notification/presentation/pages/notification_page.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/about_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/barberstuff_card_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/help_center_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/language_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/personal_info_page.dart';
import 'package:mobile_barberstuff/features/promo/presentation/pages/promo_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_brand_page.dart';
import 'package:mobile_barberstuff/features/splash/presentation/pages/splash_page.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/shared_store_entry.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_list_page.dart';
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
  static const String barberstuffCard = '/barberstuff-card';
  static const String personalInfo = '/personal-info';
  static const String language = '/language';
  static const String helpCenter = '/help-center';
  static const String about = '/about';
  static const String booking = '/booking';
  static const String notification = '/notification';
  static const String history = '/history';
  static const String storeDetail = '/store-detail';
  static const String storeList = '/store-list';
  static const String bookingSuccess = '/booking-success';
  static const String bookingReceipt = '/booking-receipt';
  static const String promo = '/promo';

  /// Aplikasi dibuka dari tautan saat masih tertutup. Tanpa ini Flutter
  /// menumpuk detail cabang di atas splash, lalu splash menimpanya waktu
  /// pindah ke beranda. Jadi selalu mulai dari splash, tautannya disimpan
  /// dan dibuka setelah user sampai di beranda.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final String? sharedStore = StoreLink.storeIdFrom(initialRoute);
    if (sharedStore != null) StoreLink.hold(sharedStore);

    return <Route<dynamic>>[
      onGenerateRoute(const RouteSettings(name: splash))!,
    ];
  }

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
      case helpCenter:
        final Object? args = settings.arguments;
        if (args is! HelpCenterArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => HelpCenterPage(args: args),
        );
      case booking:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const BookingFlowPage(),
        );
      case notification:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const NotificationPage(),
        );
      case history:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const HistoryPage(),
        );
      case storeDetail:
        final Object? args = settings.arguments;
        if (args is! StoreDetailArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => StoreDetailPage(args: args),
        );
      case storeList:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const StoreListPage(),
        );
      case bookingSuccess:
        final Object? args = settings.arguments;
        if (args is! BookingRecord) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => BookingSuccessPage(record: args),
        );
      case bookingReceipt:
        final Object? args = settings.arguments;
        if (args is! BookingRecord) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => BookingReceiptPage(record: args),
        );
      case promo:
        final Object? args = settings.arguments;
        if (args is! PromoArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => PromoPage(args: args),
        );
      case about:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AboutPage(),
        );
      case language:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const LanguagePage(),
        );
      case personalInfo:
        final Object? args = settings.arguments;
        if (args is! PersonalInfoArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => PersonalInfoPage(args: args),
        );
      case barberstuffCard:
        final Object? args = settings.arguments;
        if (args is! BarberstuffCardArgs) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => BarberstuffCardPage(args: args),
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
          builder: (BuildContext context) => const DebugShellPage(),
        );
      case verifySuccess:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const VerifySuccessPage(),
        );
      case forgotPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              ForgotPasswordPage(initialEmail: settings.arguments as String?),
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
        final String? sharedStore = StoreLink.storeIdFrom(settings.name);
        if (sharedStore == null) return null;

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              SharedStoreEntry(storeId: sharedStore),
        );
    }
  }
}
