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
  /// **'Paket'**
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
  /// **'Silver Member'**
  String get profileTierSilver;

  /// No description provided for @profileTierGold.
  ///
  /// In id, this message translates to:
  /// **'Gold Member'**
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

  /// No description provided for @bookingBranchTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Cabang'**
  String get bookingBranchTitle;

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
  /// **'Download E-Receipt'**
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
