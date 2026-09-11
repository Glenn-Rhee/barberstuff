import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/about_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/help_center_page.dart';
import 'package:mobile_barberstuff/features/profile/presentation/pages/language_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

final CustomerProfile _profile = CustomerProfile(
  id: 'c3e8da61-5135-46c2-b8ce-cdedc6177916',
  name: 'Danar Mas Pratama Nugraha',
  email: 'danarmaspratamanugraha@gmail.com',
  phoneNumber: '081388876690',
  gender: 'male',
  memberPoints: 1250,
  tier: MemberTier.silver,
  dateOfBirth: DateTime(2000, 1, 11),
);

Widget _host(Widget page, {required Locale locale}) {
  return ChangeNotifierProvider<LocalController>(
    create: (_) => LocalController(),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  );
}

const List<double> _widths = <double>[320, 360, 390, 430];
const List<double> _scales = <double>[1.0, 1.3];

void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Poppins');
    for (final String weight in <String>[
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
    ]) {
      final File file = File('assets/fonts/Poppins-$weight.ttf');
      loader.addFont(
        Future<ByteData>.value(ByteData.sublistView(file.readAsBytesSync())),
      );
    }
    await loader.load();
  });

  final Map<String, Widget> pages = <String, Widget>{
    'HelpCenterPage': HelpCenterPage(args: HelpCenterArgs(profile: _profile)),
    'AboutPage': const AboutPage(),
    'LanguagePage': const LanguagePage(),
  };

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in _widths) {
      for (final double scale in _scales) {
        testWidgets('halaman profil rapi: ${locale.languageCode} '
            '${width.toInt()}dp x$scale', (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          for (final MapEntry<String, Widget> entry in pages.entries) {
            await tester.pumpWidget(_host(entry.value, locale: locale));
            await tester.pump();

            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} overflow di ${width.toInt()}dp x$scale',
            );

            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -2000),
            );
            await tester.pump();

            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} overflow saat di-scroll',
            );
          }
        });
      }
    }
  }
}
