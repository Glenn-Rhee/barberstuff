import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/shared/widgets/animated_brand_logo.dart';
import 'package:mobile_barberstuff/shared/widgets/barber_pattern_background.dart';

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
}
