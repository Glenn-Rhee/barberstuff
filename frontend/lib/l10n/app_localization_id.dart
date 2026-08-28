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
}
