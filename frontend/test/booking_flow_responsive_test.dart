import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_flow_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';

Widget _host(BookingCatalog catalog, {required Locale locale}) {
  return ChangeNotifierProvider<BookingCatalog>.value(
    value: catalog,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BookingFlowPage(),
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

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in _widths) {
      for (final double scale in _scales) {
        testWidgets('alur booking rapi: ${locale.languageCode} '
            '${width.toInt()}dp x$scale', (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final BookingCatalog catalog = BookingCatalog();
          await tester.pumpWidget(_host(catalog, locale: locale));
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'langkah ketentuan');

          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -1500),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'ketentuan setelah scroll',
          );

          final AppLocalizations l10n = AppLocalizations.of(
            tester.element(find.byType(BookingFlowPage)),
          );

          await tester.ensureVisible(find.text(l10n.bookingTermsAgree));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.bookingTermsAgree));
          await tester.pump();
          await tester.tap(find.byType(BoxButton));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'langkah cabang');

          catalog.addStore();
          catalog.addStore();
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'cabang setelah ditambah dari panel debug',
          );

          catalog.addCapster();
          catalog.addCapster();
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'capster setelah ditambah dari panel debug',
          );
        });
      }
    }
  }
}
