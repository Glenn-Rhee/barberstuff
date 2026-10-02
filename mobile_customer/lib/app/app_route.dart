import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/deeplink/store_link.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/choose_login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/reset_password_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/reset_success_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_success_page.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_flow_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_receipt_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_success_page.dart';
import 'package:mobile_barberstuff/features/history/presentation/pages/history_page.dart';
import 'package:mobile_barberstuff/features/main_shell/presentation/pages/main_shell_page.dart';
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
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/shared_store_entry.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_list_page.dart';
import 'package:mobile_barberstuff/shared/transitions/circular_reveal_route.dart';
import 'package:provider/provider.dart';

/// Semua nama rute dan halaman yang dibukanya.
///
/// Menambah halaman baru: tambah konstanta nama di bawah, lalu satu `case`
/// di [onGenerateRoute]. Halaman yang butuh argumen pakai [_withArgs];
/// kalau argumennya salah tipe, rute dianggap tidak ada (null).
class AppRoute {
  const AppRoute._();

  // Awal aplikasi
  static const String splash = '/';
  static const String splashBrand = '/splash-brand';
  static const String onboarding = '/onboarding';

  // Auth
  static const String chooseLogin = '/choose-login';
  static const String login = '/login';
  static const String registerPage = '/register-page';
  static const String verifyOtp = '/verify-otp';
  static const String verifySuccess = '/verify-success';
  static const String completeProfile = '/complete-profile';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';

  // Beranda (shell dengan bottom nav)
  static const String home = '/home';

  // Cabang & booking
  static const String storeList = '/store-list';
  static const String storeDetail = '/store-detail';
  static const String booking = '/booking';
  static const String bookingSuccess = '/booking-success';
  static const String bookingReceipt = '/booking-receipt';
  static const String bookingDetail = '/booking-detail';
  static const String history = '/history';

  // Promo & notifikasi
  static const String promo = '/promo';
  static const String notification = '/notification';

  // Profil
  static const String personalInfo = '/personal-info';
  static const String language = '/language';
  static const String barberstuffCard = '/barberstuff-card';
  static const String helpCenter = '/help-center';
  static const String about = '/about';

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
      // Awal aplikasi
      case splash:
        return _page(settings, const SplashPage());
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
        return _page(settings, const OnboardingPage());

      // Auth
      case chooseLogin:
        return _page(settings, const ChooseLoginPage());
      case login:
        return _page(settings, const LoginPage());
      case registerPage:
        return _page(settings, const RegisterPage());
      case verifyOtp:
        return _withArgs<VerifyOtpArgs>(
          settings,
          (VerifyOtpArgs args) => VerifyOtpPage(args: args),
        );
      case verifySuccess:
        return _page(settings, const VerifySuccessPage());
      case completeProfile:
        return _withArgs<CompleteProfileArgs>(
          settings,
          (CompleteProfileArgs args) => CompleteProfilePage(args: args),
        );
      case forgotPassword:
        return _page(
          settings,
          ForgotPasswordPage(initialEmail: settings.arguments as String?),
        );
      case resetPassword:
        return _withArgs<ResetPasswordArgs>(
          settings,
          (ResetPasswordArgs args) => ResetPasswordPage(args: args),
        );
      case resetSuccess:
        return _page(settings, const ResetSuccessPage());

      // Beranda
      case home:
        return _page(settings, const MainShellPage());

      // Cabang & booking
      case storeList:
        return _page(settings, const StoreListPage());
      case storeDetail:
        return _withArgs<StoreDetailArgs>(
          settings,
          (StoreDetailArgs args) => StoreDetailPage(args: args),
        );
      case booking:
        return _page(
          settings,
          BookingFlowPage(store: settings.arguments as StoreSummary?),
        );
      case bookingSuccess:
        return _withArgs<BookingRecord>(
          settings,
          (BookingRecord record) => BookingSuccessPage(record: record),
        );
      case bookingReceipt:
        return _withArgs<BookingRecord>(
          settings,
          (BookingRecord record) => BookingReceiptPage(record: record),
        );
      case bookingDetail:
        return _withArgs<BookingRecord>(
          settings,
          (BookingRecord record) => BookingDetailPage(record: record),
        );
      case history:
        return _page(settings, const HistoryPage());

      // Promo & notifikasi
      case promo:
        return _withArgs<PromoArgs>(
          settings,
          (PromoArgs args) => PromoPage(args: args),
        );
      case notification:
        return _page(settings, const NotificationPage());

      // Profil
      case personalInfo:
        return _withArgs<PersonalInfoArgs>(
          settings,
          (PersonalInfoArgs args) => PersonalInfoPage(args: args),
        );
      case language:
        return _page(settings, const LanguagePage());
      case barberstuffCard:
        return _withArgs<BarberstuffCardArgs>(
          settings,
          (BarberstuffCardArgs args) => BarberstuffCardPage(args: args),
        );
      case helpCenter:
        return _withArgs<HelpCenterArgs>(
          settings,
          (HelpCenterArgs args) => HelpCenterPage(args: args),
        );
      case about:
        return _page(settings, const AboutPage());

      // Tautan cabang yang dibagikan, misalnya "/s/<id>".
      default:
        final String? sharedStore = StoreLink.storeIdFrom(settings.name);
        if (sharedStore == null) return null;
        return _page(settings, SharedStoreEntry(storeId: sharedStore));
    }
  }

  static Route<void> _page(RouteSettings settings, Widget page) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext _) => page,
    );
  }

  /// Halaman yang wajib menerima argumen bertipe [T].
  static Route<void>? _withArgs<T>(
    RouteSettings settings,
    Widget Function(T args) build,
  ) {
    final Object? args = settings.arguments;
    if (args is! T) return null;
    return _page(settings, build(args));
  }
}
