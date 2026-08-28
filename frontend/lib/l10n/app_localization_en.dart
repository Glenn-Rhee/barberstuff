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
}
