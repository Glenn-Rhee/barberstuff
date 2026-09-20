

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

  for (final double width in <double>[320, 390, 430]) {
    testWidgets('tombol booking selebar layar di ${width.toInt()}dp', (
      WidgetTester tester,
    ) async {
      final AppCache cache = await FakeBookingRepository.emptyCache();
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: <SingleChildWidget>[
            Provider<AppCache>.value(value: cache),
            ChangeNotifierProvider<DebugOverrides>(
              create: (_) => DebugOverrides(),
            ),
            Provider<LocationService>.value(value: LocationService(cache)),
            ChangeNotifierProvider<BookingJournal>.value(
              value: BookingJournal(cache),
            ),
            ChangeNotifierProvider<DebugOverrides>(
              create: (_) => DebugOverrides(),
            ),
            Provider<LocationService>.value(value: LocationService(cache)),
            ChangeNotifierProvider<BookingJournal>.value(
              value: BookingJournal(cache),
            ),
            Provider<BookingRepository>.value(
              value: FakeBookingRepository(cache),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BookingFlowPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size button = tester.getSize(find.byType(BoxButton));

      expect(
        button.width,
        width - 40,
        reason: 'tombol harus memenuhi lebar dikurangi padding 20 di dua sisi',
      );
      expect(
        button.height,
        greaterThanOrEqualTo(BoxButton.minHeight),
        reason: 'tinggi tombol tidak boleh menciut',
      );
    });
  }
}
