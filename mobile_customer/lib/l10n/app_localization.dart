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

  /// No description provided for @verifyResendSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get verifyResendSending;

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

  /// No description provided for @forgotPageBarText.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi'**
  String get forgotPageBarText;

  /// No description provided for @forgotHeadline.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi?'**
  String get forgotHeadline;

  /// No description provided for @forgotDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email akun Anda. Kami akan mengirimkan kode verifikasi untuk mengatur ulang kata sandi.'**
  String get forgotDescription;

  /// No description provided for @forgotSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Kirim Kode'**
  String get forgotSubmitButton;

  /// No description provided for @resetPageBarText.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi Baru'**
  String get resetPageBarText;

  /// No description provided for @resetHeadline.
  ///
  /// In id, this message translates to:
  /// **'Buat Kata Sandi Baru'**
  String get resetHeadline;

  /// No description provided for @resetDescription.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru harus berbeda dari kata sandi yang pernah Anda pakai sebelumnya.'**
  String get resetDescription;

  /// No description provided for @resetPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi Baru'**
  String get resetPasswordHint;

  /// No description provided for @resetConfirmHint.
  ///
  /// In id, this message translates to:
  /// **'Ulangi Kata Sandi Baru'**
  String get resetConfirmHint;

  /// No description provided for @resetSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Kata Sandi'**
  String get resetSubmitButton;

  /// No description provided for @resetSignInFailed.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi berhasil diubah, tetapi kami gagal masuk otomatis. Silakan masuk kembali.'**
  String get resetSignInFailed;

  /// No description provided for @resetSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat!'**
  String get resetSuccessTitle;

  /// No description provided for @resetSuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi Anda berhasil diperbarui. Anda akan diarahkan ke halaman beranda.'**
  String get resetSuccessMessage;

  /// No description provided for @resetSuccessButton.
  ///
  /// In id, this message translates to:
  /// **'Ke Beranda'**
  String get resetSuccessButton;

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

  /// No description provided for @exceptionRequestRejected.
  ///
  /// In id, this message translates to:
  /// **'Permintaan tidak dapat diproses. Periksa data Anda lalu coba lagi.'**
  String get exceptionRequestRejected;

  /// No description provided for @serverNoAccess.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses!'**
  String get serverNoAccess;

  /// No description provided for @serverReadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca data!'**
  String get serverReadFailed;

  /// No description provided for @serverBadFormat.
  ///
  /// In id, this message translates to:
  /// **'Format data tidak valid'**
  String get serverBadFormat;

  /// No description provided for @serverSessionCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Terdapat kesalahan dalam proses validasi!'**
  String get serverSessionCheckFailed;

  /// No description provided for @serverAccountGone.
  ///
  /// In id, this message translates to:
  /// **'Akun tidak ditemukan atau telah dihapus!'**
  String get serverAccountGone;

  /// No description provided for @serverTokenExpired.
  ///
  /// In id, this message translates to:
  /// **'token sudah kadaluarsa'**
  String get serverTokenExpired;

  /// No description provided for @serverTokenInvalid.
  ///
  /// In id, this message translates to:
  /// **'token tidak valid'**
  String get serverTokenInvalid;

  /// No description provided for @serverBadHeader.
  ///
  /// In id, this message translates to:
  /// **'Format header tidak valid!'**
  String get serverBadHeader;

  /// No description provided for @serverSystemError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan di sistem!'**
  String get serverSystemError;

  /// No description provided for @serverDataNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan!'**
  String get serverDataNotFound;

  /// No description provided for @serverDataGone.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan atau telah dihapus!'**
  String get serverDataGone;

  /// No description provided for @serverDataInvalid.
  ///
  /// In id, this message translates to:
  /// **'Data tidak valid!'**
  String get serverDataInvalid;

  /// No description provided for @serverDataInvalidRelogin.
  ///
  /// In id, this message translates to:
  /// **'Data tidak valid! Mohon login kembali.'**
  String get serverDataInvalidRelogin;

  /// No description provided for @serverDataInvalidContact.
  ///
  /// In id, this message translates to:
  /// **'Data tidak valid! Harap hubungi pusat.'**
  String get serverDataInvalidContact;

  /// No description provided for @serverLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengambil data!'**
  String get serverLoadFailed;

  /// No description provided for @serverPhoneFormat.
  ///
  /// In id, this message translates to:
  /// **'No telepon tidak valid, gunakan format +62xxxx atau 08xxxx'**
  String get serverPhoneFormat;

  /// No description provided for @serverMinAge.
  ///
  /// In id, this message translates to:
  /// **'Minimal usia untuk mendaftar adalah 6 bulan!'**
  String get serverMinAge;

  /// No description provided for @serverOtpSent.
  ///
  /// In id, this message translates to:
  /// **'OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.'**
  String get serverOtpSent;

  /// No description provided for @serverOtpDigitsOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya masukkan OTP berupa angka diantara 0-9'**
  String get serverOtpDigitsOnly;

  /// No description provided for @serverRegisterFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat registrasi. Coba lagi nanti.'**
  String get serverRegisterFailed;

  /// No description provided for @serverEmailVerifiedBySystem.
  ///
  /// In id, this message translates to:
  /// **'Email ini telah terdaftar dan terverifikasi oleh sistem!'**
  String get serverEmailVerifiedBySystem;

  /// No description provided for @serverEmailVerifiedUsePassword.
  ///
  /// In id, this message translates to:
  /// **'Email ini telah terdaftar dan terverifikasi! Silahkan anda login menggunakan password'**
  String get serverEmailVerifiedUsePassword;

  /// No description provided for @serverEmailVerified.
  ///
  /// In id, this message translates to:
  /// **'Email ini telah terdaftar dan terverifikasi!'**
  String get serverEmailVerified;

  /// No description provided for @serverRegisterAgain.
  ///
  /// In id, this message translates to:
  /// **'Data anda sudah tidak valid mohon register ulang dengan akun Anda.'**
  String get serverRegisterAgain;

  /// No description provided for @serverMembershipFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mencari data premium'**
  String get serverMembershipFailed;

  /// No description provided for @serverPhoneTaken.
  ///
  /// In id, this message translates to:
  /// **'No telepon ini telah terdaftar!'**
  String get serverPhoneTaken;

  /// No description provided for @serverLoginFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat login! Coba lagi nanti.'**
  String get serverLoginFailed;

  /// No description provided for @serverOtpWait.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu sebelum anda meminta OTP kembali.'**
  String get serverOtpWait;

  /// No description provided for @serverOtpExpiredResend.
  ///
  /// In id, this message translates to:
  /// **'OTP sudah kedaluwarsa. Mohon kirim ulang OTP!'**
  String get serverOtpExpiredResend;

  /// No description provided for @serverOtpExpiredRegister.
  ///
  /// In id, this message translates to:
  /// **'OTP sudah kedaluwarsa. Mohon daftar ulang / kirim ulang OTP!'**
  String get serverOtpExpiredRegister;

  /// No description provided for @serverOtpFiveWrong.
  ///
  /// In id, this message translates to:
  /// **'Anda telah melakukan kesalahan 5 kali percobaan! Mohon untuk kirim ulang OTP!'**
  String get serverOtpFiveWrong;

  /// No description provided for @serverOtpFiveTries.
  ///
  /// In id, this message translates to:
  /// **'Anda telah melakukan percobaan sebanyak 5 kali. Coba lagi nanti!'**
  String get serverOtpFiveTries;

  /// No description provided for @serverResetFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat reset password!'**
  String get serverResetFailed;

  /// No description provided for @serverResetFailedLater.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat reset password, coba lagi nanti!'**
  String get serverResetFailedLater;

  /// No description provided for @serverEmailNotRegistered.
  ///
  /// In id, this message translates to:
  /// **'Email tidak terdaftar!'**
  String get serverEmailNotRegistered;

  /// No description provided for @serverEmailUnverifiedReset.
  ///
  /// In id, this message translates to:
  /// **'Email belum verified! Tidak dapat reset password.'**
  String get serverEmailUnverifiedReset;

  /// No description provided for @serverEmailGoogleReset.
  ///
  /// In id, this message translates to:
  /// **'Email Anda login dengan google! Tidak dapat reset password.'**
  String get serverEmailGoogleReset;

  /// No description provided for @serverTooManyAttempts.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak percobaan, coba lagi nanti.'**
  String get serverTooManyAttempts;

  /// No description provided for @serverEmailUnverifiedLogin.
  ///
  /// In id, this message translates to:
  /// **'Email belum verifikasi! Verifikasi terlebih dahulu.'**
  String get serverEmailUnverifiedLogin;

  /// No description provided for @serverWrongPassword.
  ///
  /// In id, this message translates to:
  /// **'Password yang anda masukkan salah.'**
  String get serverWrongPassword;

  /// No description provided for @serverAuthFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat authentikasi'**
  String get serverAuthFailed;

  /// No description provided for @serverProviderUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Provider tidak tersedia!'**
  String get serverProviderUnavailable;

  /// No description provided for @serverGoogleUnverified.
  ///
  /// In id, this message translates to:
  /// **'Email anda belum terverifikasi oleh Google. Silahkan verifikasi terlebih dahulu'**
  String get serverGoogleUnverified;

  /// No description provided for @serverResetTokenInvalid.
  ///
  /// In id, this message translates to:
  /// **'Token tidak valid atau sudah kedaluwarsa.'**
  String get serverResetTokenInvalid;

  /// No description provided for @serverAccountNotFound.
  ///
  /// In id, this message translates to:
  /// **'Akun anda tidak ditemukan!'**
  String get serverAccountNotFound;

  /// No description provided for @serverProfileLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terdapat kesalahan saat mengambil data profile!'**
  String get serverProfileLoadFailed;

  /// No description provided for @serverProfileUpdateFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengupdate data profile user!'**
  String get serverProfileUpdateFailed;

  /// No description provided for @serverRelogin.
  ///
  /// In id, this message translates to:
  /// **'Data anda tidak valid. Mohon untuk login ulang.'**
  String get serverRelogin;

  /// No description provided for @serverProfileNoChange.
  ///
  /// In id, this message translates to:
  /// **'Update minimal 1 data profile.'**
  String get serverProfileNoChange;

  /// No description provided for @serverStoreLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengambil data toko!'**
  String get serverStoreLoadFailed;

  /// No description provided for @serverBranchNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data toko cabang yang anda cari tidak ditemukan!'**
  String get serverBranchNotFound;

  /// No description provided for @serverStoreNotFound.
  ///
  /// In id, this message translates to:
  /// **'Toko tidak ditemukan'**
  String get serverStoreNotFound;

  /// No description provided for @serverStoreGone.
  ///
  /// In id, this message translates to:
  /// **'Toko tidak ditemukan atau telah dihapus!'**
  String get serverStoreGone;

  /// No description provided for @serverStoreDataGone.
  ///
  /// In id, this message translates to:
  /// **'Data toko tidak ditemukan atau telah dihapus!'**
  String get serverStoreDataGone;

  /// No description provided for @serverStoreDataInvalid.
  ///
  /// In id, this message translates to:
  /// **'Data toko tidak valid!'**
  String get serverStoreDataInvalid;

  /// No description provided for @serverStoreIdInvalid.
  ///
  /// In id, this message translates to:
  /// **'Id toko tidak valid!'**
  String get serverStoreIdInvalid;

  /// No description provided for @serverCapsterLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengambil data capster!'**
  String get serverCapsterLoadFailed;

  /// No description provided for @serverBookingFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat membuat booking'**
  String get serverBookingFailed;

  /// No description provided for @serverBookingFailedLater.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat membuat booking. Coba lagi nanti!'**
  String get serverBookingFailedLater;

  /// No description provided for @serverStoreInvalid.
  ///
  /// In id, this message translates to:
  /// **'Toko tidak valid'**
  String get serverStoreInvalid;

  /// No description provided for @serverCapsterIdInvalid.
  ///
  /// In id, this message translates to:
  /// **'Id capster tidak valid!'**
  String get serverCapsterIdInvalid;

  /// No description provided for @serverStoreNotReady.
  ///
  /// In id, this message translates to:
  /// **'Toko belum siap menerima booking.'**
  String get serverStoreNotReady;

  /// No description provided for @serverBookingPast.
  ///
  /// In id, this message translates to:
  /// **'Tanggal dan jam booking tidak boleh kurang dari waktu sekarang.'**
  String get serverBookingPast;

  /// No description provided for @serverBookingMinLead.
  ///
  /// In id, this message translates to:
  /// **'Booking minimal 30 menit dari sekarang.'**
  String get serverBookingMinLead;

  /// No description provided for @serverUserInvalid.
  ///
  /// In id, this message translates to:
  /// **'User tidak valid!'**
  String get serverUserInvalid;

  /// No description provided for @serverUserDataInvalid.
  ///
  /// In id, this message translates to:
  /// **'Data user tidak valid!'**
  String get serverUserDataInvalid;

  /// No description provided for @serverCapsterGone.
  ///
  /// In id, this message translates to:
  /// **'Capster tidak ditemukan atau telah dihapus!'**
  String get serverCapsterGone;

  /// No description provided for @serverCapsterOtherStore.
  ///
  /// In id, this message translates to:
  /// **'Capster ini bukan merupakan bagian dari toko yang anda pilih!'**
  String get serverCapsterOtherStore;

  /// No description provided for @serverBookingExists.
  ///
  /// In id, this message translates to:
  /// **'Anda telah memiliki booking! Tidak dapat booking kembali.'**
  String get serverBookingExists;

  /// No description provided for @serverBookingSlotMismatch.
  ///
  /// In id, this message translates to:
  /// **'Jam booking tidak sesuai dengan jam tersedia.'**
  String get serverBookingSlotMismatch;

  /// No description provided for @serverBookingInProgress.
  ///
  /// In id, this message translates to:
  /// **'Anda masih memiliki booking yang sedang diproses'**
  String get serverBookingInProgress;

  /// No description provided for @serverNoCapsterLeft.
  ///
  /// In id, this message translates to:
  /// **'Sudah tidak ada capster yang tersedia.'**
  String get serverNoCapsterLeft;

  /// No description provided for @serverCapsterReserved.
  ///
  /// In id, this message translates to:
  /// **'Capster ini sedang direservasi untuk pelanggan lain.'**
  String get serverCapsterReserved;

  /// No description provided for @serverCapsterBusy.
  ///
  /// In id, this message translates to:
  /// **'Capster ini sedang tidak tersedia pada rentang waktu tersebut.'**
  String get serverCapsterBusy;

  /// No description provided for @serverSlotLocked.
  ///
  /// In id, this message translates to:
  /// **'Slot ini sudah di kunci oleh orang lain.'**
  String get serverSlotLocked;

  /// No description provided for @serverLockFirst.
  ///
  /// In id, this message translates to:
  /// **'Anda belum melakukan lock booking! Mohon untuk lock booking terlebih dahulu!'**
  String get serverLockFirst;

  /// No description provided for @serverNoLock.
  ///
  /// In id, this message translates to:
  /// **'Anda belum melakukan lock booking'**
  String get serverNoLock;

  /// No description provided for @serverLockExpired.
  ///
  /// In id, this message translates to:
  /// **'Data Booking tidak ditemukan atau waktu booking telah habis!'**
  String get serverLockExpired;

  /// No description provided for @serverBookingNotYours.
  ///
  /// In id, this message translates to:
  /// **'Data booking ini bukan milik anda!'**
  String get serverBookingNotYours;

  /// No description provided for @serverCapsterWalkIn.
  ///
  /// In id, this message translates to:
  /// **'Capster ini sedang direservasi untuk pelanggan on the spot. Mohon pilih capster lain.'**
  String get serverCapsterWalkIn;

  /// No description provided for @serverServiceInvalid.
  ///
  /// In id, this message translates to:
  /// **'Data Service tidak valid!'**
  String get serverServiceInvalid;

  /// No description provided for @serverServiceGone.
  ///
  /// In id, this message translates to:
  /// **'Service tidak ditemukan! Atau telah dihapus'**
  String get serverServiceGone;

  /// No description provided for @serverServiceNotInStore.
  ///
  /// In id, this message translates to:
  /// **'Toko ini tidak memiliki service tersebut.'**
  String get serverServiceNotInStore;

  /// No description provided for @serverServiceUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Service ini telah tidak tersedia! Mohon pilih ulang.'**
  String get serverServiceUnavailable;

  /// No description provided for @serverPromoUsed.
  ///
  /// In id, this message translates to:
  /// **'Promo ini telah digunakan'**
  String get serverPromoUsed;

  /// No description provided for @serverPromoInvalidNow.
  ///
  /// In id, this message translates to:
  /// **'Promo ini sudah tidak berlaku!'**
  String get serverPromoInvalidNow;

  /// No description provided for @serverPromoExpired.
  ///
  /// In id, this message translates to:
  /// **'Promo ini sudah kedaluwarsa!'**
  String get serverPromoExpired;

  /// No description provided for @serverPromoNotFound.
  ///
  /// In id, this message translates to:
  /// **'Promo Anda tidak ditemukan'**
  String get serverPromoNotFound;

  /// No description provided for @serverPromoInvalid.
  ///
  /// In id, this message translates to:
  /// **'Promo tidak valid'**
  String get serverPromoInvalid;

  /// No description provided for @serverScheduleLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengambil booking toko. Coba lagi nanti!'**
  String get serverScheduleLoadFailed;

  /// No description provided for @serverBookingLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat mengambil data booking!'**
  String get serverBookingLoadFailed;

  /// No description provided for @serverIdentityInvalid.
  ///
  /// In id, this message translates to:
  /// **'Identitas anda tidak valid'**
  String get serverIdentityInvalid;

  /// No description provided for @serverRatingFailed.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan saat membuat data rating!'**
  String get serverRatingFailed;

  /// No description provided for @serverBookingInvalid.
  ///
  /// In id, this message translates to:
  /// **'Booking tidak valid!'**
  String get serverBookingInvalid;

  /// No description provided for @serverRatingNeedOne.
  ///
  /// In id, this message translates to:
  /// **'Mohon menilai setidaknya satu dari toko, capster, atau staff kami.'**
  String get serverRatingNeedOne;

  /// No description provided for @serverBookingNotFound.
  ///
  /// In id, this message translates to:
  /// **'Booking tidak ditemukan!'**
  String get serverBookingNotFound;

  /// No description provided for @serverRatingCashierOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya dapat rating kasir!'**
  String get serverRatingCashierOnly;

  /// No description provided for @serverFileType.
  ///
  /// In id, this message translates to:
  /// **'Extensi file tidak didukung'**
  String get serverFileType;

  /// No description provided for @serverFileMismatch.
  ///
  /// In id, this message translates to:
  /// **'extension file tidak sesuai dengan content type'**
  String get serverFileMismatch;

  /// No description provided for @serverFileEmpty.
  ///
  /// In id, this message translates to:
  /// **'minimum upload file adalah 1 byte'**
  String get serverFileEmpty;

  /// No description provided for @serverFileTooBig.
  ///
  /// In id, this message translates to:
  /// **'maximum upload file adalah 5 mb'**
  String get serverFileTooBig;

  /// No description provided for @serverUploadUrlFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal generate URL upload.'**
  String get serverUploadUrlFailed;

  /// No description provided for @serverImageTooBig.
  ///
  /// In id, this message translates to:
  /// **'Ukuran gambar terlalu besar'**
  String get serverImageTooBig;

  /// No description provided for @serverImageKey.
  ///
  /// In id, this message translates to:
  /// **'Image url harus berupa object key.'**
  String get serverImageKey;

  /// No description provided for @serverImageSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat data, periksa image url.'**
  String get serverImageSaveFailed;

  /// No description provided for @serverFieldRequired.
  ///
  /// In id, this message translates to:
  /// **'{field} wajib diisi'**
  String serverFieldRequired(String field);

  /// No description provided for @serverFieldEmail.
  ///
  /// In id, this message translates to:
  /// **'{field} harus berupa email yang valid'**
  String serverFieldEmail(String field);

  /// No description provided for @serverFieldNumeric.
  ///
  /// In id, this message translates to:
  /// **'{field} harus berupa angka'**
  String serverFieldNumeric(String field);

  /// No description provided for @serverFieldMin.
  ///
  /// In id, this message translates to:
  /// **'{field} minimal {count} karakter'**
  String serverFieldMin(String field, String count);

  /// No description provided for @serverFieldMax.
  ///
  /// In id, this message translates to:
  /// **'{field} maksimal {count} karakter'**
  String serverFieldMax(String field, String count);

  /// No description provided for @serverFieldGreater.
  ///
  /// In id, this message translates to:
  /// **'{field} harus lebih dari {count} karakter'**
  String serverFieldGreater(String field, String count);

  /// No description provided for @serverFieldInvalid.
  ///
  /// In id, this message translates to:
  /// **'{field} tidak valid'**
  String serverFieldInvalid(String field);

  /// No description provided for @serverOtpAttemptsLeft.
  ///
  /// In id, this message translates to:
  /// **'OTP tidak valid, silahkan coba lagi. Sisa percobaan {count} kali'**
  String serverOtpAttemptsLeft(String count);

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

  /// No description provided for @validatorPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak sama'**
  String get validatorPasswordMismatch;

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

  /// No description provided for @completeProfileEmailLocked.
  ///
  /// In id, this message translates to:
  /// **'Email dari Google tidak bisa diubah'**
  String get completeProfileEmailLocked;

  /// No description provided for @avatarSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto Profil'**
  String get avatarSheetTitle;

  /// No description provided for @avatarSheetCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto'**
  String get avatarSheetCamera;

  /// No description provided for @avatarSheetGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari Galeri'**
  String get avatarSheetGallery;

  /// No description provided for @avatarSheetRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto'**
  String get avatarSheetRemove;

  /// No description provided for @avatarPickFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka galeri atau kamera. Coba lagi.'**
  String get avatarPickFailed;

  /// No description provided for @avatarPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin akses foto atau kamera ditolak. Aktifkan lewat pengaturan perangkat.'**
  String get avatarPermissionDenied;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeWelcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali'**
  String get homeWelcomeBack;

  /// No description provided for @homePoints.
  ///
  /// In id, this message translates to:
  /// **'{points} Poin'**
  String homePoints(String points);

  /// No description provided for @homeMemberBadge.
  ///
  /// In id, this message translates to:
  /// **'MEMBER'**
  String get homeMemberBadge;

  /// No description provided for @homePointsToPremium.
  ///
  /// In id, this message translates to:
  /// **'{points} Poin lagi ke level premium'**
  String homePointsToPremium(String points);

  /// No description provided for @homeMembershipLevel.
  ///
  /// In id, this message translates to:
  /// **'Tingkat membership'**
  String get homeMembershipLevel;

  /// No description provided for @homeRedeemPoints.
  ///
  /// In id, this message translates to:
  /// **'Tukarkan point anda'**
  String get homeRedeemPoints;

  /// No description provided for @homeBirthdayTitle.
  ///
  /// In id, this message translates to:
  /// **'Spesial Hari Ulang Tahun!'**
  String get homeBirthdayTitle;

  /// No description provided for @homeBirthdayDescription.
  ///
  /// In id, this message translates to:
  /// **'Diskon potongan rambut berlaku s/d 7 hari setelah ultah.'**
  String get homeBirthdayDescription;

  /// No description provided for @homeSeePromo.
  ///
  /// In id, this message translates to:
  /// **'Lihat Promo'**
  String get homeSeePromo;

  /// No description provided for @homeBirthdayBadge.
  ///
  /// In id, this message translates to:
  /// **'Tampil terbaik setiap hari'**
  String get homeBirthdayBadge;

  /// No description provided for @homeBookingNow.
  ///
  /// In id, this message translates to:
  /// **'Booking Sekarang'**
  String get homeBookingNow;

  /// No description provided for @homeActionBooking.
  ///
  /// In id, this message translates to:
  /// **'Booking'**
  String get homeActionBooking;

  /// No description provided for @homeActionPackage.
  ///
  /// In id, this message translates to:
  /// **'Toko'**
  String get homeActionPackage;

  /// No description provided for @homeActionPromo.
  ///
  /// In id, this message translates to:
  /// **'Promo'**
  String get homeActionPromo;

  /// No description provided for @homeActionHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get homeActionHistory;

  /// No description provided for @bookingBranchNewBadge.
  ///
  /// In id, this message translates to:
  /// **'NEWBIE'**
  String get bookingBranchNewBadge;

  /// No description provided for @homeBenefitTitle.
  ///
  /// In id, this message translates to:
  /// **'Benefit Barberstuff'**
  String get homeBenefitTitle;

  /// No description provided for @homeBenefitPoints.
  ///
  /// In id, this message translates to:
  /// **'Poin reward setiap kali potong rambut'**
  String get homeBenefitPoints;

  /// No description provided for @homeBenefitBirthday.
  ///
  /// In id, this message translates to:
  /// **'Diskon khusus dan penawaran ulang tahun'**
  String get homeBenefitBirthday;

  /// No description provided for @homeBenefitPriority.
  ///
  /// In id, this message translates to:
  /// **'Prioritas jadwal tanpa antre panjang'**
  String get homeBenefitPriority;

  /// No description provided for @homeBenefitDiscountTitle.
  ///
  /// In id, this message translates to:
  /// **'Diskon Lebih Banyak Cukur!'**
  String get homeBenefitDiscountTitle;

  /// No description provided for @homeBenefitPointsTitle.
  ///
  /// In id, this message translates to:
  /// **'Poin di Setiap Potongan'**
  String get homeBenefitPointsTitle;

  /// No description provided for @homeBenefitPriorityTitle.
  ///
  /// In id, this message translates to:
  /// **'Prioritas Tanpa Antre'**
  String get homeBenefitPriorityTitle;

  /// No description provided for @homeActiveBookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking Aktif'**
  String get homeActiveBookingTitle;

  /// No description provided for @homeBookingUpcoming.
  ///
  /// In id, this message translates to:
  /// **'MENDATANG'**
  String get homeBookingUpcoming;

  /// No description provided for @homeBookingOrderId.
  ///
  /// In id, this message translates to:
  /// **'Order ID #{id}'**
  String homeBookingOrderId(String id);

  /// No description provided for @homeBookingDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat Detail'**
  String get homeBookingDetail;

  /// No description provided for @homeBookingCapster.
  ///
  /// In id, this message translates to:
  /// **'Capster {name}'**
  String homeBookingCapster(String name);

  /// No description provided for @homeBookingEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada booking aktif.'**
  String get homeBookingEmpty;

  /// No description provided for @homeNearbyTitle.
  ///
  /// In id, this message translates to:
  /// **'Cabang Terdekat'**
  String get homeNearbyTitle;

  /// No description provided for @homeNearbySeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get homeNearbySeeAll;

  /// No description provided for @storeListTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua Cabang'**
  String get storeListTitle;

  /// No description provided for @homeNearbyDistance.
  ///
  /// In id, this message translates to:
  /// **'{distance} km'**
  String homeNearbyDistance(String distance);

  /// No description provided for @homeHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Potongan'**
  String get homeHistoryTitle;

  /// No description provided for @homeHistorySeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Riwayat'**
  String get homeHistorySeeAll;

  /// No description provided for @homeHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat potongan.'**
  String get homeHistoryEmpty;

  /// No description provided for @homeHistoryRebook.
  ///
  /// In id, this message translates to:
  /// **'Pesan Lagi'**
  String get homeHistoryRebook;

  /// No description provided for @homeHistoryBy.
  ///
  /// In id, this message translates to:
  /// **'oleh {name}'**
  String homeHistoryBy(String name);

  /// No description provided for @homeNearbyLocation.
  ///
  /// In id, this message translates to:
  /// **'{city} • {distance} km'**
  String homeNearbyLocation(String city, String distance);

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBooking.
  ///
  /// In id, this message translates to:
  /// **'Booking'**
  String get navBooking;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Booking'**
  String get historyTitle;

  /// No description provided for @storeDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Toko'**
  String get storeDetailTitle;

  /// No description provided for @storeOpen.
  ///
  /// In id, this message translates to:
  /// **'BUKA'**
  String get storeOpen;

  /// No description provided for @storeClosed.
  ///
  /// In id, this message translates to:
  /// **'TUTUP'**
  String get storeClosed;

  /// No description provided for @storeReviewCount.
  ///
  /// In id, this message translates to:
  /// **'({count} ulasan)'**
  String storeReviewCount(String count);

  /// No description provided for @storeActionCall.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get storeActionCall;

  /// No description provided for @storeActionRoute.
  ///
  /// In id, this message translates to:
  /// **'Rute'**
  String get storeActionRoute;

  /// No description provided for @storeActionShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get storeActionShare;

  /// No description provided for @storeBarbers.
  ///
  /// In id, this message translates to:
  /// **'Barber Kami'**
  String get storeBarbers;

  /// No description provided for @storeSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get storeSeeAll;

  /// No description provided for @storeTabAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang Kami'**
  String get storeTabAbout;

  /// No description provided for @storeTabService.
  ///
  /// In id, this message translates to:
  /// **'Layanan'**
  String get storeTabService;

  /// No description provided for @storeTabPackage.
  ///
  /// In id, this message translates to:
  /// **'Paket'**
  String get storeTabPackage;

  /// No description provided for @storeTabReview.
  ///
  /// In id, this message translates to:
  /// **'Ulasan'**
  String get storeTabReview;

  /// No description provided for @storeDescription.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get storeDescription;

  /// No description provided for @storeHours.
  ///
  /// In id, this message translates to:
  /// **'Jam Operasional'**
  String get storeHours;

  /// No description provided for @storeHoursEveryday.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari'**
  String get storeHoursEveryday;

  /// No description provided for @storeAddressTitle.
  ///
  /// In id, this message translates to:
  /// **'Alamat Kami'**
  String get storeAddressTitle;

  /// No description provided for @storeSeeMap.
  ///
  /// In id, this message translates to:
  /// **'Lihat di Peta'**
  String get storeSeeMap;

  /// No description provided for @storeServicesTitle.
  ///
  /// In id, this message translates to:
  /// **'Services Kami'**
  String get storeServicesTitle;

  /// No description provided for @storePackagesTitle.
  ///
  /// In id, this message translates to:
  /// **'Paket Kami'**
  String get storePackagesTitle;

  /// No description provided for @storeReviewsTitle.
  ///
  /// In id, this message translates to:
  /// **'Ulasan Pelanggan'**
  String get storeReviewsTitle;

  /// No description provided for @storeBookNow.
  ///
  /// In id, this message translates to:
  /// **'Pesan Sekarang'**
  String get storeBookNow;

  /// No description provided for @storeTypeCount.
  ///
  /// In id, this message translates to:
  /// **'{count} jenis'**
  String storeTypeCount(int count);

  /// No description provided for @storeShareCopied.
  ///
  /// In id, this message translates to:
  /// **'Info toko disalin ke clipboard'**
  String get storeShareCopied;

  /// No description provided for @storeShareMessage.
  ///
  /// In id, this message translates to:
  /// **'{name}\n{address}\n\nLihat detail & booking di BarberStuff:\n{link}'**
  String storeShareMessage(String name, String address, String link);

  /// No description provided for @storeBookCta.
  ///
  /// In id, this message translates to:
  /// **'Booking Sekarang'**
  String get storeBookCta;

  /// No description provided for @storeBookClosed.
  ///
  /// In id, this message translates to:
  /// **'Cabang Sedang Tutup'**
  String get storeBookClosed;

  /// No description provided for @storeNoBarber.
  ///
  /// In id, this message translates to:
  /// **'Belum ada barber di cabang ini.'**
  String get storeNoBarber;

  /// No description provided for @storeNoService.
  ///
  /// In id, this message translates to:
  /// **'Belum ada layanan.'**
  String get storeNoService;

  /// No description provided for @storeNoPackage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada paket.'**
  String get storeNoPackage;

  /// No description provided for @storeNoReview.
  ///
  /// In id, this message translates to:
  /// **'Belum ada ulasan.'**
  String get storeNoReview;

  /// No description provided for @historyTabUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Akan Datang'**
  String get historyTabUpcoming;

  /// No description provided for @historyTabDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get historyTabDone;

  /// No description provided for @historyTabCanceled.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get historyTabCanceled;

  /// No description provided for @historyBadgeProgress.
  ///
  /// In id, this message translates to:
  /// **'PROGRESS'**
  String get historyBadgeProgress;

  /// No description provided for @historyBadgeDone.
  ///
  /// In id, this message translates to:
  /// **'DONE'**
  String get historyBadgeDone;

  /// No description provided for @historyBadgeCancel.
  ///
  /// In id, this message translates to:
  /// **'CANCEL'**
  String get historyBadgeCancel;

  /// No description provided for @historyNotReviewed.
  ///
  /// In id, this message translates to:
  /// **'Belum diulas'**
  String get historyNotReviewed;

  /// No description provided for @historyWriteReview.
  ///
  /// In id, this message translates to:
  /// **'Beri Ulasan'**
  String get historyWriteReview;

  /// No description provided for @historySeeReview.
  ///
  /// In id, this message translates to:
  /// **'Lihat Ulasan'**
  String get historySeeReview;

  /// No description provided for @historyYourReview.
  ///
  /// In id, this message translates to:
  /// **'Ulasanmu'**
  String get historyYourReview;

  /// No description provided for @historyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada booking di daftar ini.'**
  String get historyEmpty;

  /// No description provided for @reviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana pengalamanmu?'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'pengalamanmu sangat berharga bagi kami'**
  String get reviewSubtitle;

  /// No description provided for @reviewCapster.
  ///
  /// In id, this message translates to:
  /// **'Pelayanan Capster'**
  String get reviewCapster;

  /// No description provided for @reviewCashier.
  ///
  /// In id, this message translates to:
  /// **'Pelayanan Kasir'**
  String get reviewCashier;

  /// No description provided for @reviewStore.
  ///
  /// In id, this message translates to:
  /// **'Kualitas Outlet'**
  String get reviewStore;

  /// No description provided for @reviewMessageLabel.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan Pengalamanmu Disini'**
  String get reviewMessageLabel;

  /// No description provided for @reviewMessageHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis disini untuk riview kamu!'**
  String get reviewMessageHint;

  /// No description provided for @reviewSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get reviewSubmit;

  /// No description provided for @reviewNeedStars.
  ///
  /// In id, this message translates to:
  /// **'Beri bintang dulu untuk semua penilaian.'**
  String get reviewNeedStars;

  /// No description provided for @reviewThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih atas ulasanmu!'**
  String get reviewThanks;

  /// No description provided for @notificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationTitle;

  /// No description provided for @notificationSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari notifikasi...'**
  String get notificationSearchHint;

  /// No description provided for @notificationFilterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get notificationFilterAll;

  /// No description provided for @notificationFilterUnread.
  ///
  /// In id, this message translates to:
  /// **'Belum Dibaca'**
  String get notificationFilterUnread;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In id, this message translates to:
  /// **'Tandai semua dibaca'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get notificationToday;

  /// No description provided for @notificationYesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get notificationYesterday;

  /// No description provided for @notificationEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi saat ini'**
  String get notificationEmpty;

  /// No description provided for @notificationChannelName.
  ///
  /// In id, this message translates to:
  /// **'Info Barberstuff'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In id, this message translates to:
  /// **'Info booking, poin, dan promo Barberstuff.'**
  String get notificationChannelDescription;

  /// No description provided for @notificationTimeNow.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get notificationTimeNow;

  /// No description provided for @notificationTimeMinute.
  ///
  /// In id, this message translates to:
  /// **'{count} mnt lalu'**
  String notificationTimeMinute(int count);

  /// No description provided for @notificationTimeHour.
  ///
  /// In id, this message translates to:
  /// **'{count} jam lalu'**
  String notificationTimeHour(int count);

  /// No description provided for @notificationTimeDay.
  ///
  /// In id, this message translates to:
  /// **'{count} hari lalu'**
  String notificationTimeDay(int count);

  /// No description provided for @notificationBookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Booking Dikonfirmasi!'**
  String get notificationBookingTitle;

  /// No description provided for @notificationBookingBody.
  ///
  /// In id, this message translates to:
  /// **'Pemesanan Anda untuk layanan cukur di cabang Jati Asih telah dikonfirmasi oleh barber.'**
  String get notificationBookingBody;

  /// No description provided for @notificationPointsTitle.
  ///
  /// In id, this message translates to:
  /// **'Poin Member Bertambah!'**
  String get notificationPointsTitle;

  /// No description provided for @notificationPointsBody.
  ///
  /// In id, this message translates to:
  /// **'Anda mendapatkan 150 poin tambahan dari transaksi cukur terakhir Anda. Tingkatkan terus level Anda!'**
  String get notificationPointsBody;

  /// No description provided for @notificationMembershipTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat, Level Member Naik!'**
  String get notificationMembershipTitle;

  /// No description provided for @notificationMembershipBody.
  ///
  /// In id, this message translates to:
  /// **'Anda telah mencapai level Premium! Nikmati berbagai keuntungan eksklusif tanpa antre.'**
  String get notificationMembershipBody;

  /// No description provided for @notificationRecommendationTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi Gaya Rambut Baru'**
  String get notificationRecommendationTitle;

  /// No description provided for @notificationRecommendationBody.
  ///
  /// In id, this message translates to:
  /// **'Temukan tren gaya rambut pria terbaru tahun ini yang cocok dengan bentuk wajah Anda.'**
  String get notificationRecommendationBody;

  /// No description provided for @profileTierSilver.
  ///
  /// In id, this message translates to:
  /// **'Silver Member Barberstuff'**
  String get profileTierSilver;

  /// No description provided for @profileTierGold.
  ///
  /// In id, this message translates to:
  /// **'Gold Member Barberstuff'**
  String get profileTierGold;

  /// No description provided for @profileTierPlatinum.
  ///
  /// In id, this message translates to:
  /// **'Platinum Member'**
  String get profileTierPlatinum;

  /// No description provided for @profileMenuPersonalInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Pribadi'**
  String get profileMenuPersonalInfo;

  /// No description provided for @profileMenuLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get profileMenuLanguage;

  /// No description provided for @profileMenuCard.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff Card'**
  String get profileMenuCard;

  /// No description provided for @profileMenuNotification.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get profileMenuNotification;

  /// No description provided for @profileMenuHelp.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get profileMenuHelp;

  /// No description provided for @profileMenuAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get profileMenuAbout;

  /// No description provided for @profileMenuLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileMenuLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari akun?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In id, this message translates to:
  /// **'Anda perlu masuk lagi untuk memakai Barberstuff.'**
  String get profileLogoutMessage;

  /// No description provided for @languagePageTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get languagePageTitle;

  /// No description provided for @languagePageDescription.
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih bahasa yang nyaman bagi Anda untuk menikmati pengalaman terbaik bersama kami.'**
  String get languagePageDescription;

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get languageEnglish;

  /// No description provided for @languageSelectAction.
  ///
  /// In id, this message translates to:
  /// **'Pilih'**
  String get languageSelectAction;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @cardPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff Card'**
  String get cardPageTitle;

  /// No description provided for @cardIdLabel.
  ///
  /// In id, this message translates to:
  /// **'ID User'**
  String get cardIdLabel;

  /// No description provided for @personalInfoTitle.
  ///
  /// In id, this message translates to:
  /// **'Informasi Pribadi'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoChangePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ganti Foto Profil'**
  String get personalInfoChangePhoto;

  /// No description provided for @personalInfoPhotoFormat.
  ///
  /// In id, this message translates to:
  /// **'Support Format: JPEG, PNG, JPG'**
  String get personalInfoPhotoFormat;

  /// No description provided for @personalInfoEmailLocked.
  ///
  /// In id, this message translates to:
  /// **'Email dipakai untuk masuk dan tidak bisa diubah'**
  String get personalInfoEmailLocked;

  /// No description provided for @personalInfoBirthDateLocked.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir mengikuti data pendaftaran dan tidak bisa diubah'**
  String get personalInfoBirthDateLocked;

  /// No description provided for @personalInfoPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Password Saya'**
  String get personalInfoPasswordTitle;

  /// No description provided for @personalInfoPasswordSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti Password Saya'**
  String get personalInfoPasswordSubtitle;

  /// No description provided for @personalInfoPasswordAction.
  ///
  /// In id, this message translates to:
  /// **'Ganti Sekarang'**
  String get personalInfoPasswordAction;

  /// No description provided for @personalInfoSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get personalInfoSave;

  /// No description provided for @personalInfoSaved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan tersimpan'**
  String get personalInfoSaved;

  /// No description provided for @helpTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get helpTitle;

  /// No description provided for @helpHeadline.
  ///
  /// In id, this message translates to:
  /// **'Butuh Bantuan? Ceritakan Masalah Anda'**
  String get helpHeadline;

  /// No description provided for @helpSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Isi formulir di bawah ini dan tim kami akan menghubungi Anda secepatnya.'**
  String get helpSubtitle;

  /// No description provided for @helpNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get helpNameLabel;

  /// No description provided for @helpProblemLabel.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan Masalah Anda'**
  String get helpProblemLabel;

  /// No description provided for @helpProblemHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis masalah yang Anda alami'**
  String get helpProblemHint;

  /// No description provided for @helpSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get helpSubmit;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutTitle;

  /// No description provided for @aboutLastUpdated.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diperbarui: {date}'**
  String aboutLastUpdated(String date);

  /// No description provided for @aboutIntro.
  ///
  /// In id, this message translates to:
  /// **'Dengan mengakses atau menggunakan aplikasi Barberstuff, Anda setuju untuk terikat pada Ketentuan Penggunaan ini.'**
  String get aboutIntro;

  /// No description provided for @aboutAcceptanceTitle.
  ///
  /// In id, this message translates to:
  /// **'1. Penerimaan Ketentuan'**
  String get aboutAcceptanceTitle;

  /// No description provided for @aboutAcceptanceBody.
  ///
  /// In id, this message translates to:
  /// **'Dengan menggunakan Barberstuff, Anda menyatakan telah membaca, memahami, dan menyetujui Ketentuan Penggunaan ini.'**
  String get aboutAcceptanceBody;

  /// No description provided for @aboutEligibilityTitle.
  ///
  /// In id, this message translates to:
  /// **'2. Kelayakan'**
  String get aboutEligibilityTitle;

  /// No description provided for @aboutEligibilityBody.
  ///
  /// In id, this message translates to:
  /// **'Anda harus berusia minimal 17 tahun atau memiliki izin dari orang tua maupun wali untuk menggunakan Barberstuff.'**
  String get aboutEligibilityBody;

  /// No description provided for @aboutAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'3. Akun Pengguna'**
  String get aboutAccountTitle;

  /// No description provided for @aboutAccountPoint1.
  ///
  /// In id, this message translates to:
  /// **'Anda bertanggung jawab menjaga kerahasiaan akun Anda'**
  String get aboutAccountPoint1;

  /// No description provided for @aboutAccountPoint2.
  ///
  /// In id, this message translates to:
  /// **'Seluruh informasi yang diberikan harus akurat dan terkini'**
  String get aboutAccountPoint2;

  /// No description provided for @aboutAccountPoint3.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff tidak bertanggung jawab atas akses tidak sah yang disebabkan kelalaian pengguna'**
  String get aboutAccountPoint3;

  /// No description provided for @aboutUsageTitle.
  ///
  /// In id, this message translates to:
  /// **'4. Penggunaan Layanan'**
  String get aboutUsageTitle;

  /// No description provided for @aboutUsageIntro.
  ///
  /// In id, this message translates to:
  /// **'Anda setuju untuk tidak:'**
  String get aboutUsageIntro;

  /// No description provided for @aboutUsagePoint1.
  ///
  /// In id, this message translates to:
  /// **'Menggunakan Barberstuff untuk tujuan melanggar hukum'**
  String get aboutUsagePoint1;

  /// No description provided for @aboutUsagePoint2.
  ///
  /// In id, this message translates to:
  /// **'Menyalin, menyebarkan, atau mengeksploitasi konten platform tanpa izin'**
  String get aboutUsagePoint2;

  /// No description provided for @aboutUsagePoint3.
  ///
  /// In id, this message translates to:
  /// **'Mengunggah konten yang melanggar hukum atau hak pihak ketiga'**
  String get aboutUsagePoint3;

  /// No description provided for @aboutIpTitle.
  ///
  /// In id, this message translates to:
  /// **'5. Hak Kekayaan Intelektual'**
  String get aboutIpTitle;

  /// No description provided for @aboutIpBody.
  ///
  /// In id, this message translates to:
  /// **'Seluruh konten, sistem, dan desain platform dimiliki oleh Barberstuff. Data dan materi yang dibuat pengguna tetap menjadi milik pengguna.'**
  String get aboutIpBody;

  /// No description provided for @aboutTerminationTitle.
  ///
  /// In id, this message translates to:
  /// **'6. Penghentian Akun'**
  String get aboutTerminationTitle;

  /// No description provided for @aboutTerminationBody.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff berhak menangguhkan atau menghentikan akun yang melanggar Ketentuan ini.'**
  String get aboutTerminationBody;

  /// No description provided for @aboutDisclaimerTitle.
  ///
  /// In id, this message translates to:
  /// **'7. Penafian'**
  String get aboutDisclaimerTitle;

  /// No description provided for @aboutDisclaimerBody.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff disediakan sebagaimana adanya dan sebagaimana tersedia, tanpa jaminan dalam bentuk apa pun.'**
  String get aboutDisclaimerBody;

  /// No description provided for @aboutChangesTitle.
  ///
  /// In id, this message translates to:
  /// **'8. Perubahan Ketentuan'**
  String get aboutChangesTitle;

  /// No description provided for @aboutChangesBody.
  ///
  /// In id, this message translates to:
  /// **'Barberstuff dapat memperbarui Ketentuan ini sewaktu-waktu. Penggunaan platform yang berkelanjutan menandakan penerimaan atas Ketentuan yang diperbarui.'**
  String get aboutChangesBody;

  /// No description provided for @bookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking'**
  String get bookingTitle;

  /// No description provided for @bookingBranchTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Cabang'**
  String get bookingBranchTitle;

  /// No description provided for @bookingStepLabel.
  ///
  /// In id, this message translates to:
  /// **'LANGKAH {current} DARI {total}'**
  String bookingStepLabel(int current, int total);

  /// No description provided for @bookingBranchSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tentukan cabang barbershop terdekat kamu'**
  String get bookingBranchSubtitle;

  /// No description provided for @bookingScheduleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal dan jam yang tersedia'**
  String get bookingScheduleSubtitle;

  /// No description provided for @bookingBarberSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih barber favoritmu atau biarkan kami memilihkan'**
  String get bookingBarberSubtitle;

  /// No description provided for @bookingServiceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih layanan yang kamu inginkan'**
  String get bookingServiceSubtitle;

  /// No description provided for @bookingConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Booking'**
  String get bookingConfirmTitle;

  /// No description provided for @bookingDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Booking'**
  String get bookingDetailTitle;

  /// No description provided for @bookingConfirmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Harap periksa kembali detail pesanan Anda'**
  String get bookingConfirmSubtitle;

  /// No description provided for @bookingNextSchedule.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Pilih Jadwal'**
  String get bookingNextSchedule;

  /// No description provided for @bookingNextBarber.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Pilih Capster'**
  String get bookingNextBarber;

  /// No description provided for @bookingNextService.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Pilih Layanan'**
  String get bookingNextService;

  /// No description provided for @bookingNextConfirm.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Konfirmasi Booking'**
  String get bookingNextConfirm;

  /// No description provided for @bookingConfirmCta.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Pesanan'**
  String get bookingConfirmCta;

  /// No description provided for @bookingSlotFullNote.
  ///
  /// In id, this message translates to:
  /// **'Slot yang tidak dapat dipilih sudah penuh'**
  String get bookingSlotFullNote;

  /// No description provided for @bookingSlotEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jam tersedia di tanggal ini.'**
  String get bookingSlotEmpty;

  /// No description provided for @bookingSlotTooSoon.
  ///
  /// In id, this message translates to:
  /// **'Booking minimal 30 menit dari sekarang.'**
  String get bookingSlotTooSoon;

  /// No description provided for @bookingTabService.
  ///
  /// In id, this message translates to:
  /// **'Service'**
  String get bookingTabService;

  /// No description provided for @bookingAvailableToday.
  ///
  /// In id, this message translates to:
  /// **'Tersedia hari ini'**
  String get bookingAvailableToday;

  /// No description provided for @bookingLockRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa waktu {time}'**
  String bookingLockRemaining(String time);

  /// No description provided for @bookingLockExpired.
  ///
  /// In id, this message translates to:
  /// **'Waktu kunci habis. Silakan pilih jadwal lagi.'**
  String get bookingLockExpired;

  /// No description provided for @bookingCancelTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan booking?'**
  String get bookingCancelTitle;

  /// No description provided for @bookingCancelMessage.
  ///
  /// In id, this message translates to:
  /// **'Slot yang sudah dikunci akan dilepas dan bisa diambil orang lain.'**
  String get bookingCancelMessage;

  /// No description provided for @bookingCancelConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, batalkan'**
  String get bookingCancelConfirm;

  /// No description provided for @bookingReleaseFailed.
  ///
  /// In id, this message translates to:
  /// **'Slot barber belum terlepas. Tunggu sebentar lalu tekan Lanjut lagi.'**
  String get bookingReleaseFailed;

  /// No description provided for @bookingCancelKeep.
  ///
  /// In id, this message translates to:
  /// **'Lanjut booking'**
  String get bookingCancelKeep;

  /// No description provided for @bookingConfirmBranch.
  ///
  /// In id, this message translates to:
  /// **'CABANG'**
  String get bookingConfirmBranch;

  /// No description provided for @bookingConfirmService.
  ///
  /// In id, this message translates to:
  /// **'LAYANAN'**
  String get bookingConfirmService;

  /// No description provided for @bookingConfirmBarber.
  ///
  /// In id, this message translates to:
  /// **'BARBER'**
  String get bookingConfirmBarber;

  /// No description provided for @bookingConfirmSchedule.
  ///
  /// In id, this message translates to:
  /// **'WAKTU & TANGGAL'**
  String get bookingConfirmSchedule;

  /// No description provided for @bookingPaymentTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Pembayaran'**
  String get bookingPaymentTitle;

  /// No description provided for @bookingSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get bookingSubtotal;

  /// No description provided for @bookingAppFee.
  ///
  /// In id, this message translates to:
  /// **'Biaya Layanan Aplikasi'**
  String get bookingAppFee;

  /// No description provided for @bookingTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Pembayaran'**
  String get bookingTotal;

  /// No description provided for @bookingBarberTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Barber'**
  String get bookingBarberTitle;

  /// No description provided for @bookingTermsHeadline.
  ///
  /// In id, this message translates to:
  /// **'📋 Ketentuan Booking Barberstuff'**
  String get bookingTermsHeadline;

  /// No description provided for @bookingTermsIntro.
  ///
  /// In id, this message translates to:
  /// **'Untuk memberikan pelayanan terbaik dan menjaga jadwal tetap teratur, setiap pelanggan diharapkan mengikuti ketentuan booking yang berlaku.'**
  String get bookingTermsIntro;

  /// No description provided for @bookingTermsRulesLabel.
  ///
  /// In id, this message translates to:
  /// **'💡 Aturan Booking:'**
  String get bookingTermsRulesLabel;

  /// No description provided for @bookingTermsRule1.
  ///
  /// In id, this message translates to:
  /// **'Booking dilakukan minimal 1 jam sebelum jadwal kedatangan'**
  String get bookingTermsRule1;

  /// No description provided for @bookingTermsRule2.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan diharapkan datang sesuai waktu yang telah dipilih'**
  String get bookingTermsRule2;

  /// No description provided for @bookingTermsRule3.
  ///
  /// In id, this message translates to:
  /// **'Toleransi keterlambatan maksimal 5 menit'**
  String get bookingTermsRule3;

  /// No description provided for @bookingTermsRule4.
  ///
  /// In id, this message translates to:
  /// **'Keterlambatan lebih dari 5 menit dapat menyebabkan booking dibatalkan secara otomatis'**
  String get bookingTermsRule4;

  /// No description provided for @bookingTermsOutro.
  ///
  /// In id, this message translates to:
  /// **'Pastikan datang tepat waktu agar proses pelayanan dapat berjalan nyaman dan sesuai jadwal. Terima kasih atas pengertiannya! 😊'**
  String get bookingTermsOutro;

  /// No description provided for @bookingTermsAgree.
  ///
  /// In id, this message translates to:
  /// **'Saya sudah baca ketentuan'**
  String get bookingTermsAgree;

  /// No description provided for @bookingNearbyHeadline.
  ///
  /// In id, this message translates to:
  /// **'Pilih Barberstuff Terdekat!'**
  String get bookingNearbyHeadline;

  /// No description provided for @bookingSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Ketik disini!'**
  String get bookingSearchHint;

  /// No description provided for @bookingViewStore.
  ///
  /// In id, this message translates to:
  /// **'Lihat Toko'**
  String get bookingViewStore;

  /// No description provided for @bookingStoreEmpty.
  ///
  /// In id, this message translates to:
  /// **'Cabang tidak ditemukan.'**
  String get bookingStoreEmpty;

  /// No description provided for @bookingCapsterEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada capster di cabang ini.'**
  String get bookingCapsterEmpty;

  /// No description provided for @commonContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get commonContinue;

  /// No description provided for @bookingScheduleTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Jadwal'**
  String get bookingScheduleTitle;

  /// No description provided for @bookingServiceTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Layanan'**
  String get bookingServiceTitle;

  /// No description provided for @bookingDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get bookingDateLabel;

  /// No description provided for @bookingTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get bookingTimeLabel;

  /// No description provided for @bookingSingleServiceLabel.
  ///
  /// In id, this message translates to:
  /// **'Jasa Satuan'**
  String get bookingSingleServiceLabel;

  /// No description provided for @bookingPackageLabel.
  ///
  /// In id, this message translates to:
  /// **'Paket'**
  String get bookingPackageLabel;

  /// No description provided for @bookingServiceSingleOnly.
  ///
  /// In id, this message translates to:
  /// **'Mohon maaf, layanan hanya menerima satu layanan per booking. Pilih satu dulu, sisanya booking terpisah.'**
  String get bookingServiceSingleOnly;

  /// No description provided for @bookingServiceEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada layanan tersedia.'**
  String get bookingServiceEmpty;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemesanan Berhasil!'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Pemesanan Anda telah berhasil dilakukan'**
  String get bookingSuccessMessage;

  /// No description provided for @bookingSuccessReceipt.
  ///
  /// In id, this message translates to:
  /// **'Lihat Bukti Pesanan'**
  String get bookingSuccessReceipt;

  /// No description provided for @bookingSuccessHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get bookingSuccessHome;

  /// No description provided for @receiptTitle.
  ///
  /// In id, this message translates to:
  /// **'E-Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptStore.
  ///
  /// In id, this message translates to:
  /// **'Barber/Salon'**
  String get receiptStore;

  /// No description provided for @receiptAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get receiptAddress;

  /// No description provided for @receiptName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get receiptName;

  /// No description provided for @receiptPhone.
  ///
  /// In id, this message translates to:
  /// **'No Telepon'**
  String get receiptPhone;

  /// No description provided for @receiptDate.
  ///
  /// In id, this message translates to:
  /// **'Tgl Booking'**
  String get receiptDate;

  /// No description provided for @receiptTime.
  ///
  /// In id, this message translates to:
  /// **'Jam Booking'**
  String get receiptTime;

  /// No description provided for @receiptSpecialist.
  ///
  /// In id, this message translates to:
  /// **'Specialist'**
  String get receiptSpecialist;

  /// No description provided for @receiptTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Harga'**
  String get receiptTotal;

  /// No description provided for @receiptDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh E-Receipt'**
  String get receiptDownload;

  /// No description provided for @comingSoonMessage.
  ///
  /// In id, this message translates to:
  /// **'Segera hadir!'**
  String get comingSoonMessage;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get commonRetry;

  /// No description provided for @offlineCachedData.
  ///
  /// In id, this message translates to:
  /// **'Sedang offline — menampilkan data tersimpan'**
  String get offlineCachedData;

  /// No description provided for @permissionNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get permissionNotificationTitle;

  /// No description provided for @permissionNotificationMessage.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi supaya kamu tahu saat booking dikonfirmasi dan poin bertambah.'**
  String get permissionNotificationMessage;

  /// No description provided for @permissionLocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Izinkan lokasi'**
  String get permissionLocationTitle;

  /// No description provided for @permissionLocationMessage.
  ///
  /// In id, this message translates to:
  /// **'Lokasi dipakai untuk mengurutkan cabang dari yang terdekat denganmu.'**
  String get permissionLocationMessage;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get permissionOpenSettings;

  /// No description provided for @permissionLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get permissionLater;

  /// No description provided for @permissionLocationOffTitle.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan lokasi'**
  String get permissionLocationOffTitle;

  /// No description provided for @permissionLocationOffMessage.
  ///
  /// In id, this message translates to:
  /// **'Layanan lokasi di HP kamu sedang mati. Nyalakan dulu supaya jarak cabang bisa dihitung.'**
  String get permissionLocationOffMessage;

  /// No description provided for @permissionOpenLocationSettings.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan Lokasi'**
  String get permissionOpenLocationSettings;

  /// No description provided for @commonUnderstood.
  ///
  /// In id, this message translates to:
  /// **'Oke'**
  String get commonUnderstood;

  /// No description provided for @commonLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get commonLogout;

  /// No description provided for @promoTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Promo'**
  String get promoTitle;

  /// No description provided for @promoGradeTitle.
  ///
  /// In id, this message translates to:
  /// **'Keuntungan Grade Ini'**
  String get promoGradeTitle;

  /// No description provided for @promoTerms.
  ///
  /// In id, this message translates to:
  /// **'S&K Berlaku'**
  String get promoTerms;

  /// No description provided for @promoSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Promo'**
  String get promoSectionTitle;

  /// No description provided for @promoSectionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Promo menarik dari barberstuff, untuk pengguna'**
  String get promoSectionSubtitle;

  /// No description provided for @promoRedeemTitle.
  ///
  /// In id, this message translates to:
  /// **'Tukar Poin'**
  String get promoRedeemTitle;

  /// No description provided for @promoRedeemSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tukarkan poin Anda dengan berbagai voucher menarik.'**
  String get promoRedeemSubtitle;

  /// No description provided for @promoClaim.
  ///
  /// In id, this message translates to:
  /// **'Klaim'**
  String get promoClaim;

  /// No description provided for @promoClaimReward.
  ///
  /// In id, this message translates to:
  /// **'Klaim Hadiah'**
  String get promoClaimReward;

  /// No description provided for @promoAboutVoucher.
  ///
  /// In id, this message translates to:
  /// **'Tentang Voucher'**
  String get promoAboutVoucher;

  /// No description provided for @promoClaimed.
  ///
  /// In id, this message translates to:
  /// **'Hadiah berhasil diklaim.'**
  String get promoClaimed;

  /// No description provided for @promoNotEnoughPoints.
  ///
  /// In id, this message translates to:
  /// **'Poin belum cukup untuk menukar hadiah ini.'**
  String get promoNotEnoughPoints;

  /// No description provided for @promoBenefitPointsTitle.
  ///
  /// In id, this message translates to:
  /// **'A-Poin Reguler'**
  String get promoBenefitPointsTitle;

  /// No description provided for @promoBenefitPointsDesc.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan cashback poin reguler hingga 5% untuk setiap transaksi merchant mitra.'**
  String get promoBenefitPointsDesc;

  /// No description provided for @promoBenefitMerchantTitle.
  ///
  /// In id, this message translates to:
  /// **'Promo Merchant'**
  String get promoBenefitMerchantTitle;

  /// No description provided for @promoBenefitMerchantDesc.
  ///
  /// In id, this message translates to:
  /// **'Diskon eksklusif s.d 30% di berbagai restoran, kafe, dan outlet favorit terpilih.'**
  String get promoBenefitMerchantDesc;

  /// No description provided for @promoBenefitVoucherTitle.
  ///
  /// In id, this message translates to:
  /// **'Voucher Spesial Hari Raya'**
  String get promoBenefitVoucherTitle;

  /// No description provided for @promoBenefitVoucherDesc.
  ///
  /// In id, this message translates to:
  /// **'Hadiah langsung berupa voucher belanja senilai Rp100.000 saat momen spesial.'**
  String get promoBenefitVoucherDesc;

  /// No description provided for @promoBannerCashbackTitle.
  ///
  /// In id, this message translates to:
  /// **'Cashback 20%'**
  String get promoBannerCashbackTitle;

  /// No description provided for @promoBannerCashbackSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Untuk semua layanan'**
  String get promoBannerCashbackSubtitle;

  /// No description provided for @promoBannerCashbackFootnote.
  ///
  /// In id, this message translates to:
  /// **'Min. transaksi Rp150.000'**
  String get promoBannerCashbackFootnote;

  /// No description provided for @promoBannerBundleTitle.
  ///
  /// In id, this message translates to:
  /// **'Paket Hemat'**
  String get promoBannerBundleTitle;

  /// No description provided for @promoBannerBundleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Haircut 5x'**
  String get promoBannerBundleSubtitle;

  /// No description provided for @promoBannerBundleFootnote.
  ///
  /// In id, this message translates to:
  /// **'Hemat hingga 15%'**
  String get promoBannerBundleFootnote;

  /// No description provided for @promoRewardHalfOffTitle.
  ///
  /// In id, this message translates to:
  /// **'Diskon 50% Potong Rambut'**
  String get promoRewardHalfOffTitle;

  /// No description provided for @promoRewardHalfOffDesc.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan akses eksklusif untuk potongan harga layanan potong rambut dan perawatan jenggot pilihan. Nikmati hasil cukur terbaik langsung dari barber profesional kami dengan standar pelayanan premium.'**
  String get promoRewardHalfOffDesc;

  /// No description provided for @promoRewardPriorityTitle.
  ///
  /// In id, this message translates to:
  /// **'Akses Antrean Prioritas Cukur'**
  String get promoRewardPriorityTitle;

  /// No description provided for @promoRewardPriorityDesc.
  ///
  /// In id, this message translates to:
  /// **'Lewati antrean dan langsung dilayani di cabang pilihanmu. Berlaku untuk satu kali kunjungan pada jam operasional normal.'**
  String get promoRewardPriorityDesc;

  /// No description provided for @promoRewardWashTitle.
  ///
  /// In id, this message translates to:
  /// **'Gratis Keramas & Hair Tonic'**
  String get promoRewardWashTitle;

  /// No description provided for @promoRewardWashDesc.
  ///
  /// In id, this message translates to:
  /// **'Tambahan keramas dan hair tonic tanpa biaya untuk setiap layanan potong rambut. Berlaku di seluruh cabang Barberstuff.'**
  String get promoRewardWashDesc;

  /// No description provided for @promoPoints.
  ///
  /// In id, this message translates to:
  /// **'{count} Poin'**
  String promoPoints(String count);

  /// No description provided for @promoXp.
  ///
  /// In id, this message translates to:
  /// **'{count} XP'**
  String promoXp(String count);

  /// No description provided for @promoProgress.
  ///
  /// In id, this message translates to:
  /// **'{owned}/{needed}'**
  String promoProgress(String owned, String needed);
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
