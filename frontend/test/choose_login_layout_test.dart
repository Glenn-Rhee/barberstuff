import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/theme/app_theme.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/choose_login_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

const List<List<double>> _devices = <List<double>>[
  <double>[720, 1280, 2.25],
  <double>[1080, 1920, 3.0],
  <double>[1080, 2340, 2.75],
  <double>[750, 1334, 2.0],
  <double>[1284, 2778, 3.0],
];

void main() {
  for (final List<double> device in _devices) {
    for (final String lang in <String>['id', 'en']) {
      for (final double scale in <double>[1.0, 1.3]) {
        final String name =
            'choose login rapi di ${device[0].toInt()}x${device[1].toInt()} '
            '($lang, textScale $scale)';

        testWidgets(name, (WidgetTester tester) async {
          tester.view.physicalSize = Size(device[0], device[1]);
          tester.view.devicePixelRatio = device[2];
          addTearDown(tester.view.reset);

          final List<String> errors = <String>[];
          final void Function(FlutterErrorDetails)? previous =
              FlutterError.onError;
          FlutterError.onError = (FlutterErrorDetails details) {
            errors.add(details.exceptionAsString().split('\n').first);
          };

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (BuildContext context, Widget? child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const ChooseLoginPage(),
            ),
          );
          await tester.pump();

          final double screenWidth = device[0] / device[2];
          final List<Size> buttons = tester
              .renderObjectList<RenderBox>(find.byType(BoxButton))
              .map((RenderBox box) => box.size)
              .toList();

          FlutterError.onError = previous;

          expect(buttons, hasLength(2));
          for (final Size size in buttons) {
            expect(size.width, lessThanOrEqualTo(screenWidth));
            expect(size.height, greaterThanOrEqualTo(BoxButton.minHeight));
          }
          expect(buttons.first.width, buttons.last.width);

          expect(find.byType(Scrollable), findsOneWidget);
          expect(errors.toSet(), isEmpty, reason: errors.toSet().join(' | '));
        });
      }
    }
  }

  testWidgets('label tombol tidak terpotong di layar sempit', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChooseLoginPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    expect(find.text('Masuk dengan Kata Sandi'), findsOneWidget);

    final Finder labels = find.descendant(
      of: find.byType(BoxButton),
      matching: find.byType(Text),
    );
    expect(labels, findsNWidgets(2));
    for (final Text text in tester.widgetList<Text>(labels)) {
      expect(text.overflow, isNot(TextOverflow.ellipsis));
    }
  });
}
