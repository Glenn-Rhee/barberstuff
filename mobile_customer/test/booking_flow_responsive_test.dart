

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_flow_page.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'support/fake_booking_repository.dart';

Widget _host(BookingRepository repo, AppCache cache, {required Locale locale}) {
  return MultiProvider(
    providers: <SingleChildWidget>[
      Provider<AppCache>.value(value: cache),
      ChangeNotifierProvider<DebugOverrides>(create: (_) => DebugOverrides()),
      Provider<LocationService>.value(value: LocationService(cache)),
      ChangeNotifierProvider<BookingJournal>.value(
        value: BookingJournal(cache),
      ),
      Provider<BookingRepository>.value(value: repo),
    ],
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

          final AppCache cache = await FakeBookingRepository.emptyCache();
          final BookingRepository repo = FakeBookingRepository(cache);
          await tester.pumpWidget(_host(repo, cache, locale: locale));
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

          await tester.tap(
            find.text(FakeBookingRepository.sampleStore.name).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(BoxButton));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'langkah jadwal');

          await tester.tap(find.text('20:00').first);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(BoxButton));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'langkah capster');
        });
      }
    }
  }
}
