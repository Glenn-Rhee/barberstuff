import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_theme.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/widgets/onboarding_action.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Layar uji: lebar fisik, tinggi fisik, devicePixelRatio.
const List<List<double>> _devices = <List<double>>[
  <double>[1080, 2340, 2.75],
  <double>[1080, 1920, 3.0],
  <double>[750, 1334, 2.0],
  <double>[1284, 2778, 3.0],
];

void main() {
  for (final List<double> device in _devices) {
    for (final String lang in <String>['id', 'en']) {
      for (final double scale in <double>[1.0, 1.3]) {
        final String name =
            'onboarding rapi di ${device[0].toInt()}x${device[1].toInt()} '
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

          final Widget app = MaterialApp(
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
            home: const OnboardingPage(),
          );

          await tester.pumpWidget(app);

          // Gambar harus benar-benar ter-decode supaya ukurannya nyata,
          // bukan 0x0 seperti default di widget test.
          await tester.runAsync(() async {
            final BuildContext context = tester.element(
              find.byType(OnboardingPage),
            );
            for (final String path in <String>[
              AppAssets.onboardingFirst,
              AppAssets.onboardingSecond,
              AppAssets.onboardingThird,
            ]) {
              await precacheImage(AssetImage(path), context);
            }
          });
          await tester.pumpWidget(app);
          await tester.pump();

          final double screenWidth = device[0] / device[2];
          final RenderBox image =
              tester.renderObject(find.byType(Image).first) as RenderBox;
          final RenderBox shade =
              tester.renderObject(find.byType(ShaderMask).first) as RenderBox;
          final Size imageSize = image.size;
          final Offset imageOrigin = image.localToGlobal(Offset.zero);
          final Size shadeSize = shade.size;

          // Semua slide harus aman, bukan cuma yang pertama.
          for (int i = 0; i < 2; i++) {
            await tester.drag(find.byType(PageView), const Offset(-500, 0));
            await tester.pumpAndSettle();
          }

          // Kembalikan handler dulu, baru assert. Kalau dibalik, kegagalan
          // expect malah ketutup assertion internal flutter_test.
          FlutterError.onError = previous;

          // Gambar melebar penuh dan mentok ke ujung atas layar.
          expect(imageSize.width, screenWidth);
          expect(imageOrigin, Offset.zero);

          // Shading memudarkan persis seluas area gambar.
          expect(shadeSize, imageSize);

          expect(errors.toSet(), isEmpty, reason: errors.toSet().join(' | '));
        });
      }
    }
  }

  testWidgets('tombol onboarding tidak tertimpa navigasi bawah', (
    WidgetTester tester,
  ) async {
    const double navBar = 48;
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(bottom: navBar),
            viewPadding: const EdgeInsets.only(bottom: navBar),
          ),
          child: child!,
        ),
        home: const OnboardingPage(),
      ),
    );
    await tester.pump();

    final double safeBottom = 2160 / 3.0 - navBar;
    expect(
      tester.getRect(find.byType(OnboardingAction)).bottom,
      lessThanOrEqualTo(safeBottom),
    );
  });
}
