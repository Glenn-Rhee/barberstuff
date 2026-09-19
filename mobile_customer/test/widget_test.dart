import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/shared/widgets/animated_brand_logo.dart';
import 'package:mobile_barberstuff/shared/widgets/barber_pattern_background.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';

void main() {
  testWidgets('animated brand logo renders and reports intro completion', (
    WidgetTester tester,
  ) async {
    bool introFinished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedBrandLogo(
              width: 220,
              duration: const Duration(milliseconds: 300),
              onIntroEnd: () => introFinished = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(introFinished, isFalse);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(introFinished, isTrue);
  });

  testWidgets('brand logo tint wraps the image in a color filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedBrandLogo(width: 220, tint: AppColor.surface),
          ),
        ),
      ),
    );

    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('pattern background paints behind its child', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BarberPatternBackground(
          backgroundColor: AppColor.orangeLight,
          patternColor: AppColor.surface,
          patternIntensity: 2.4,
          child: Text('content', textDirection: TextDirection.ltr),
        ),
      ),
    );

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(DecoratedBox), findsWidgets);
  });

  testWidgets('box loader: tiga batang memanjang bergantian', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BoxLoader(size: 48))),
      ),
    );

    Finder bars() => find.descendant(
      of: find.byType(BoxLoader),
      matching: find.byType(Container),
    );

    List<double> heights() => bars()
        .evaluate()
        .map(
          (Element e) => tester
              .getSize(find.byElementPredicate((Element x) => x == e))
              .height,
        )
        .toList();

    expect(bars(), findsNWidgets(BoxLoader.barCount));

    final List<double> first = heights();
    await tester.pump(BoxLoader.cycle ~/ 3);
    final List<double> second = heights();

    expect(
      first,
      isNot(equals(second)),
      reason: 'tinggi batang harus berubah seiring putaran',
    );
    expect(
      second.reduce((double a, double b) => a > b ? a : b),
      greaterThan(second.reduce((double a, double b) => a < b ? a : b)),
      reason: 'batang memanjang bergantian, tidak serentak',
    );
  });
}
