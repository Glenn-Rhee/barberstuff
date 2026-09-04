import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localization_en.dart';
import 'app_localization_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff'**
  String get appTitle;

  /// No description provided for @onboardingFirstTitle.
  ///
  /// In id, this message translates to:
  /// **'Gaya yang pas untuk keseharianmu'**
  String get onboardingFirstTitle;

  /// No description provided for @onboardingFirstDescription.
  ///
  /// In id, this message translates to:
  /// **'Temukan gaya rambut yang sesuai dengan karakter dan aktivitas harianmu.'**
  String get onboardingFirstDescription;

  /// No description provided for @onboardingSecondTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking cukur jadi lebih mudah'**
  String get onboardingSecondTitle;

  /// No description provided for @onboardingSecondDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih cabang, barber, dan jam yang kamu mau tanpa perlu antre di tempat.'**
  String get onboardingSecondDescription;

  /// No description provided for @onboardingThirdTitle.
  ///
  /// In id, this message translates to:
  /// **'Nikmati berbagai keuntungan member'**
  String get onboardingThirdTitle;

  /// No description provided for @onboardingThirdDescription.
  ///
  /// In id, this message translates to:
  /// **'Kumpulkan poin di setiap kunjungan dan tukarkan dengan potongan harga.'**
  String get onboardingThirdDescription;

  /// No description provided for @onboardingStart.
  ///
  /// In id, this message translates to:
  /// **'Ayo Mulai!'**
  String get onboardingStart;

  /// No description provided for @chooseLoginWelcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get chooseLoginWelcome;

  /// No description provided for @chooseLoginGoogleText.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dengan Google'**
  String get chooseLoginGoogleText;

  /// No description provided for @chooseLoginDividerOr.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get chooseLoginDividerOr;

  /// No description provided for @chooseLoginWithPasswordText.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Kata Sandi'**
  String get chooseLoginWithPasswordText;

  /// No description provided for @chooseLoginTextMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get chooseLoginTextMessage;

  /// No description provided for @chooseLoginTextLink.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get chooseLoginTextLink;

  /// No description provided for @genderMale.
  ///
  /// In id, this message translates to:
  /// **'Laki-laki'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In id, this message translates to:
  /// **'Perempuan'**
  String get genderFemale;

  /// No description provided for @registerHeadline.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Anda'**
  String get registerHeadline;

  /// No description provided for @registerNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get registerNameLabel;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor Telepon'**
  String get registerPhoneLabel;

  /// No description provided for @registerBirthDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Lahir'**
  String get registerBirthDateLabel;

  /// No description provided for @registerGenderLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis Kelamin'**
  String get registerGenderLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get registerPasswordLabel;

  /// No description provided for @registerSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get registerSubmitButton;

  /// No description provided for @registerHaveAccountQuestion.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get registerHaveAccountQuestion;

  /// No description provided for @registerLoginAction.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get registerLoginAction;

  /// No description provided for @registerOtpSentMessage.
  ///
  /// In id, this message translates to:
  /// **'OTP telah dikirim ke email Anda.'**
  String get registerOtpSentMessage;

  /// No description provided for @verifyPageBarText.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Email'**
  String get verifyPageBarText;

  /// No description provided for @verifyHeadline.
  ///
  /// In id, this message translates to:
  /// **'Periksa Email Anda'**
  String get verifyHeadline;

  /// No description provided for @verifyDescription.
  ///
  /// In id, this message translates to:
  /// **'Kami telah mengirimkan kode verifikasi 6 digit ke {email}. Silakan masukkan kode di bawah ini.'**
  String verifyDescription(String email);

  /// No description provided for @verifySubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get verifySubmitButton;

  /// No description provided for @verifyResendQuestion.
  ///
  /// In id, this message translates to:
  /// **'Tidak menerima kode?'**
  String get verifyResendQuestion;

  /// No description provided for @verifyResendAction.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode'**
  String get verifyResendAction;

  /// No description provided for @verifyResendCountdown.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang dalam {time}'**
  String verifyResendCountdown(String time);

  /// No description provided for @verifyAttemptExhausted.
  ///
  /// In id, this message translates to:
  /// **'Kesempatan mencoba habis. Silakan kirim ulang kode.'**
  String get verifyAttemptExhausted;

  /// No description provided for @verifyResendSuccess.
  ///
  /// In id, this message translates to:
  /// **'Kode baru telah dikirim ke email Anda.'**
  String get verifyResendSuccess;

  /// No description provided for @verifySuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat!'**
  String get verifySuccessTitle;

  /// No description provided for @verifySuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Email Anda telah berhasil diverifikasi. Anda sekarang dapat mengakses semua fitur aplikasi kami.'**
  String get verifySuccessMessage;

  /// No description provided for @verifySuccessButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get verifySuccessButton;

  /// No description provided for @loginHeadline.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Akun Anda'**
  String get loginHeadline;

  /// No description provided for @loginEmailHint.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get loginPasswordHint;

  /// No description provided for @loginRememberMe.
  ///
  /// In id, this message translates to:
  /// **'Ingat Saya'**
  String get loginRememberMe;

  /// No description provided for @loginSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginSubmitButton;

  /// No description provided for @loginForgotQuestion.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get loginForgotQuestion;

  /// No description provided for @loginForgotAction.
  ///
  /// In id, this message translates to:
  /// **'Klik disini'**
  String get loginForgotAction;

  /// No description provided for @loginWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get loginWithGoogle;

  /// No description provided for @exceptionReceiveTimeout.
  ///
  /// In id, this message translates to:
  /// **'Koneksi timeout. Periksa jaringan Anda.'**
  String get exceptionReceiveTimeout;

  /// No description provided for @exceptionConnectionError.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server.'**
  String get exceptionConnectionError;

  /// No description provided for @exceptionDefaultType.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan pada server.'**
  String get exceptionDefaultType;

  /// No description provided for @exceptionDefault.
  ///
  /// In id, this message translates to:
  /// **'Terjadi Kesalahan yang tak terduga.'**
  String get exceptionDefault;

  /// No description provided for @validatorRequired.
  ///
  /// In id, this message translates to:
  /// **'{label} wajib diisi'**
  String validatorRequired(String label);

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordMin.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi minimal {min} karakter'**
  String validatorPasswordMin(int min);

  /// No description provided for @validatorPhoneMin.
  ///
  /// In id, this message translates to:
  /// **'Nomor Telepon minimal {min} digit'**
  String validatorPhoneMin(int min);

  /// No description provided for @validatorPhoneMax.
  ///
  /// In id, this message translates to:
  /// **'Nomor Telepon maksimal {max} digit'**
  String validatorPhoneMax(int max);

  /// No description provided for @validatorPhoneDigits.
  ///
  /// In id, this message translates to:
  /// **'Hanya boleh angka'**
  String get validatorPhoneDigits;

  /// No description provided for @googleSignInFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk dengan Google. Silakan coba lagi.'**
  String get googleSignInFailed;

  /// No description provided for @completeProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi Profil'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sedikit lagi. Lengkapi data dirimu untuk mulai memakai Barberstuff.'**
  String get completeProfileSubtitle;

  /// No description provided for @completeProfileSubmit.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get completeProfileSubmit;

  /// No description provided for @comingSoonTitle.
  ///
  /// In id, this message translates to:
  /// **'Segera hadir'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonMessage.
  ///
  /// In id, this message translates to:
  /// **'Kami masih mengerjakan fitur ini. Sementara itu, silakan gunakan fitur-fitur yang sudah tersedia. Terima kasih.'**
  String get comingSoonMessage;

  /// No description provided for @commonUnderstood.
  ///
  /// In id, this message translates to:
  /// **'Mengerti'**
  String get commonUnderstood;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
