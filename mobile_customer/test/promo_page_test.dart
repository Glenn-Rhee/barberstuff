import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/promo/presentation/pages/promo_page.dart';
import 'package:mobile_barberstuff/features/promo/promo_injection.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

const List<double> _widths = <double>[320, 360, 390, 430];
const List<double> _scales = <double>[1.0, 1.3];

CustomerProfile _profile({int points = 1250}) {
  return CustomerProfile(
    id: 'cust-1',
    name: 'Iqbal',
    email: 'iqbal@example.com',
    phoneNumber: '081234567890',
    gender: 'male',
    memberPoints: points,
    tier: MemberTier.gold,
  );
}

Widget _host(Locale locale, {int points = 1250}) {
  return MultiProvider(
    providers: promoProviders(),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PromoPage(
        args: PromoArgs(profile: _profile(points: points)),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    final FontLoader loader = FontLoader('Poppins');
    for (final String w in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final File f = File('assets/fonts/Poppins-$w.ttf');
      loader.addFont(
        Future<ByteData>.value(ByteData.sublistView(f.readAsBytesSync())),
      );
    }
    await loader.load();
  });

  testWidgets('menampilkan grade, promo, dan daftar tukar poin', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const Locale('id')));
    await tester.pumpAndSettle();

    expect(find.text('Keuntungan Grade Ini'), findsOneWidget);
    expect(find.text('Tukar Poin'), findsOneWidget);
    expect(find.text('A-Poin Reguler'), findsOneWidget);
    expect(find.text('Diskon 50% Potong Rambut'), findsOneWidget);
  });

  testWidgets('poin kurang menampilkan bilah kemajuan, bukan tombol klaim', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const Locale('id'), points: 100));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Klaim').first);
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Klaim Hadiah'), findsNothing);
  });

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in _widths) {
      for (final double scale in _scales) {
        testWidgets('promo tanpa overflow: '
            '${locale.languageCode} ${width.toInt()}dp x$scale', (
          WidgetTester tester,
        ) async {
          tester.view.physicalSize = Size(width, 1400);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(_host(locale));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
