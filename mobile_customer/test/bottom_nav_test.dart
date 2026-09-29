import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/dashboard_bottom_nav.dart';

Widget _host() {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      backgroundColor: AppColor.surface,
      body: const SizedBox.expand(),
      bottomNavigationBar: DashboardBottomNav(
        current: DashboardTab.home,
        onSelect: (DashboardTab _) {},
      ),
    ),
  );
}

void main() {
  testWidgets('sudut membulat tidak memakai border tak seragam', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(DashboardBottomNav),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final BoxDecoration decoration = box.decoration as BoxDecoration;

    expect(decoration.borderRadius, isNotNull);
    expect(
      decoration.border == null || decoration.border!.isUniform,
      isTrue,
      reason: 'borderRadius hanya boleh dipakai dengan border seragam',
    );
  });

  testWidgets('empat tab tampil dengan label', (WidgetTester tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
