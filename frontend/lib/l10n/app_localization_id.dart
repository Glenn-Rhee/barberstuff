// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localization.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Barberstuff';

  @override
  String get bookingTitle => 'Pesan Layanan';

  @override
  String greeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String queueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orang mengantre',
      one: '1 orang mengantre',
      zero: 'Antrean kosong',
    );
    return '$_temp0';
  }

  @override
  String get onboardingFirstTitle => 'Gaya yang pas untuk keseharianmu';

  @override
  String get onboardingFirstDescription =>
      'Temukan gaya rambut yang sesuai dengan karakter dan aktivitas harianmu.';

  @override
  String get onboardingSecondTitle => 'Booking cukur jadi lebih mudah';

  @override
  String get onboardingSecondDescription =>
      'Pilih cabang, barber, dan jam yang kamu mau tanpa perlu antre di tempat.';

  @override
  String get onboardingThirdTitle => 'Nikmati berbagai keuntungan member';

  @override
  String get onboardingThirdDescription =>
      'Kumpulkan poin di setiap kunjungan dan tukarkan dengan potongan harga.';

  @override
  String get onboardingStart => 'Ayo Mulai!';

  @override
  String get chooseLoginWelcome => 'Selamat Datang';

  @override
  String get chooseLoginGoogleText => 'Lanjutkan dengan Google';

  @override
  String get chooseLoginDividerOr => 'atau';

  @override
  String get chooseLoginWithPasswordText => 'Masuk dengan Kata Sandi';

  @override
  String get chooseLoginTextMessage => 'Belum punya akun?';

  @override
  String get chooseLoginTextLink => 'Daftar';

  @override
  String get commonProcessing => 'Memproses...';

  @override
  String get commonSuccess => 'Berhasil';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get registerPageBarText => 'Daftar';

  @override
  String get registerHeadline => 'Buat Akun Anda';

  @override
  String get registerSubheadline =>
      'Isi data diri kamu untuk jadi Barberstuff.';

  @override
  String get registerNameLabel => 'Nama Lengkap';

  @override
  String get registerPhoneLabel => 'Nomor Telepon';

  @override
  String get registerBirthDateLabel => 'Tanggal Lahir';

  @override
  String get registerGenderLabel => 'Jenis Kelamin';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Kata Sandi';

  @override
  String get registerSubmitButton => 'Daftar';

  @override
  String get registerHaveAccountQuestion => 'Sudah punya akun?';

  @override
  String get registerLoginAction => 'Masuk';

  @override
  String get registerOtpSentMessage => 'OTP telah dikirim ke email Anda.';

  @override
  String get verifyPageBarText => 'Verifikasi Email';

  @override
  String get verifyHeadline => 'Periksa Email Anda';

  @override
  String verifyDescription(String email) {
    return 'Kami telah mengirimkan kode verifikasi 6 digit ke $email. Silakan masukkan kode di bawah ini.';
  }

  @override
  String get verifySubmitButton => 'Verifikasi';

  @override
  String get verifyResendQuestion => 'Tidak menerima kode?';

  @override
  String get verifyResendAction => 'Kirim ulang kode';

  @override
  String verifyResendCountdown(int seconds) {
    return 'Kirim ulang dalam $seconds detik';
  }

  @override
  String get verifyResendSuccess => 'Kode baru telah dikirim ke email Anda.';

  @override
  String get verifySuccessTitle => 'Selamat!';

  @override
  String get verifySuccessMessage =>
      'Email Anda telah berhasil diverifikasi. Anda sekarang dapat mengakses semua fitur aplikasi kami.';

  @override
  String get verifySuccessButton => 'Lanjutkan';

  @override
  String get loginHeadline => 'Masuk ke Akun Anda';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Kata Sandi';

  @override
  String get loginRememberMe => 'Ingat Saya';

  @override
  String get loginSubmitButton => 'Masuk';

  @override
  String get loginForgotQuestion => 'Lupa kata sandi?';

  @override
  String get loginForgotAction => 'Klik disini';

  @override
  String get loginWithGoogle => 'Masuk dengan Google';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get comingSoonTitle => 'Segera hadir';

  @override
  String get comingSoonMessage =>
      'Kami masih mengerjakan fitur ini. Sementara itu, silakan gunakan fitur-fitur yang sudah tersedia. Terima kasih.';

  @override
  String get commonUnderstood => 'Mengerti';
}
