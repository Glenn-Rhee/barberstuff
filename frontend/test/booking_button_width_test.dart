import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_flow_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';

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
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookingCatalog>(
          create: (_) => BookingCatalog(),
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
