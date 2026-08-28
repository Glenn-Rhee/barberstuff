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
}
