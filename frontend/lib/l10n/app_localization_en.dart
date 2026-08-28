// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Barberstuff';

  @override
  String get bookingTitle => 'Book a Service';

  @override
  String greeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String queueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people in queue',
      one: '1 person in queue',
      zero: 'No one in queue',
    );
    return '$_temp0';
  }

  @override
  String get onboardingFirstTitle => 'Style that fits your day';

  @override
  String get onboardingFirstDescription =>
      'Find a cut that matches your character and daily routine.';

  @override
  String get onboardingSecondTitle => 'Booking made simple';

  @override
  String get onboardingSecondDescription =>
      'Pick your branch, barber, and time slot without queueing.';

  @override
  String get onboardingThirdTitle => 'Enjoy member benefits';

  @override
  String get onboardingThirdDescription =>
      'Collect points on every visit and redeem them for discounts.';

  @override
  String get onboardingStart => 'Get Started!';
}
