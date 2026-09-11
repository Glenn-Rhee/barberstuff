import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/features/notification/presentation/pages/notification_page.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

const List<double> _widths = <double>[320, 360, 390, 430];
const List<double> _scales = <double>[1.0, 1.3];

void main() {
  setUpAll(() async {
    await initializeDateFormatting();

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

  Future<void> pumpPage(
    WidgetTester tester,
    NotificationProvider provider,
    Locale locale,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: provider,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NotificationPage(),
        ),
      ),
    );
    await tester.pump();
  }

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in _widths) {
      for (final double scale in _scales) {
        testWidgets(
          'notifikasi tanpa overflow: '
          '${locale.languageCode} ${width.toInt()}dp x$scale',
          (WidgetTester tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );

            final NotificationProvider provider = NotificationProvider();
            addTearDown(provider.dispose);

            await pumpPage(tester, provider, locale);
            expect(tester.takeException(), isNull, reason: 'daftar penuh');

            provider.markAllRead();
            provider.setFilter(NotificationFilter.unread);
            await tester.pump();
            expect(tester.takeException(), isNull, reason: 'state kosong');

            provider.reset();
            provider.push();
            await tester.pump();
            expect(tester.takeException(), isNull, reason: 'notifikasi baru');
          },
        );
      }
    }
  }

  testWidgets('simulator menambah notifikasi lalu berhenti', (
    WidgetTester tester,
  ) async {
    final NotificationProvider provider = NotificationProvider();
    addTearDown(provider.dispose);

    final int before = provider.items.length;
    expect(provider.isSimulating, isFalse);

    provider.push();
    expect(provider.items.length, before + 1);
    expect(provider.items.first.isRead, isFalse);

    provider.markAllRead();
    expect(provider.items.every((dynamic n) => n.isRead), isTrue);

    provider.clear();
    expect(provider.items, isEmpty);

    provider.reset();
    expect(provider.items.length, before);
  });
}
