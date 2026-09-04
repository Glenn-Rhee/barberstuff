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

  testWidgets('box loader: jejak menumpuk lalu bersih tiap putaran', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BoxLoader(size: 48))),
      ),
    );

    List<Rect> rectsOf(Color color) {
      final Offset root = tester.getRect(find.byType(BoxLoader)).topLeft;
      return find
          .byWidgetPredicate((Widget w) => w is Image && w.color == color)
          .evaluate()
          .map(
            (Element e) => tester
                .getRect(find.byElementPredicate((Element x) => x == e))
                .shift(-root),
          )
          .toList();
    }

    Rect trailArea() => rectsOf(
      AppColor.cream,
    ).reduce((Rect a, Rect b) => a.expandToInclude(b));

    Rect head() => rectsOf(AppColor.orangeLight).single;

    expect(rectsOf(AppColor.cream), hasLength(1));
    expect(trailArea(), head(), reason: 'awal putaran belum ada jejak');

    await tester.pump(const Duration(milliseconds: 200));
    expect(rectsOf(AppColor.cream), hasLength(1));
    expect(
      trailArea().width,
      greaterThan(head().width),
      reason: 'jejak memanjang mulus mengikuti oranye',
    );

    for (final ({int gap, int count}) tick in <({int gap, int count})>[
      (gap: 400, count: 2),
      (gap: 400, count: 3),
      (gap: 400, count: 4),
    ]) {
      await tester.pump(Duration(milliseconds: tick.gap));
      expect(
        rectsOf(AppColor.cream),
        hasLength(tick.count),
        reason: 'jejak bertambah tiap langkah',
      );
      expect(trailArea().expandToInclude(head()), trailArea());
    }

    await tester.pump(const Duration(milliseconds: 200));
    expect(
      rectsOf(AppColor.cream),
      hasLength(1),
      reason: 'jejak harus bersih saat putaran mengulang',
    );
  });
}
