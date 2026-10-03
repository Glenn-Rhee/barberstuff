import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/home/presentation/models/dashboard_content.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/active_booking_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/benefit_carousel.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/birthday_promo_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/history_tile.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/points_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/quick_action_row.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/section_header.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/dashboard_bottom_nav.dart';

Widget _host(Widget child, {required Locale locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

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

  final Map<String, Widget> subjects = <String, Widget>{
    'PointsCard': PointsCard(
      points: 1250,
      tier: MemberTier.silver,
      onTap: () {},
    ),
    'BirthdayPromoCard': BirthdayPromoCard(
      discountPercent: 30,
      onBooking: () {},
    ),
    'QuickActionRow': QuickActionRow(onSelect: (QuickAction _) {}),
    'SectionHeader': SectionHeader(
      title: 'Riwayat Potongan',
      actionLabel: 'Lihat Riwayat',
      onAction: () {},
    ),
    'ActiveBookingCard': ActiveBookingCard(
      booking: ActiveBooking(
        orderId: '9821',
        storeName: 'Pondok Gede',
        storeAddress:
            'Gg. Leopard Jl. Jatimakmur No.49C, RT.001/RW.011, Kota Bekasi',
        capsterName: 'Danarmas',
        schedule: DateTime(2026, 5, 25, 16),
      ),
      onDetail: () {},
    ),
    'HistoryTile': HistoryTile(
      history: HaircutHistory(
        id: '1',
        serviceName: 'Anti Frizz and Treatment Premium',
        capsterName: 'Ariel Rizki Muhtamad Bakri',
        date: DateTime(2026, 5, 8),
        storeName: 'Kemang Raya',
        price: 95000,
      ),
      onTap: () {},
      onRebook: () {},
    ),
    'DashboardBottomNav': DashboardBottomNav(
      current: DashboardTab.home,
      onSelect: (DashboardTab _) {},
    ),
  };

  final Map<String, Widget> fullWidthSubjects = <String, Widget>{
    'BenefitCarousel': BenefitCarousel(
      horizontalPadding: 20,
      benefits: const <BenefitItem>[
        BenefitItem(
          title: 'Diskon Lebih Banyak Cukur!',
          description:
              'Diskon potongan rambut berlaku s/d 7 hari setelah ultah.',
          imageAsset: AppAssets.promoScissors,
        ),
      ],
    ),
    'NearbyStoreList': NearbyStoreList(
      stores: const <NearbyStore>[
        NearbyStore(
          id: '1',
          name: 'Pondok Indah',
          city: 'Jakarta Selatan',
          rating: 4.9,
          distanceKm: 0.7,
        ),
      ],
      horizontalPadding: 20,
      onSelect: (NearbyStore _) {},
      onBooking: (NearbyStore _) {},
    ),
  };

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in _widths) {
      for (final double scale in _scales) {
        testWidgets(
          'tanpa overflow: ${locale.languageCode} ${width.toInt()}dp x$scale',
          (WidgetTester tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );

            for (final MapEntry<String, Widget> entry in subjects.entries) {
              await tester.pumpWidget(
                _host(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: entry.value,
                  ),
                  locale: locale,
                ),
              );
              await tester.pump();

              expect(
                tester.takeException(),
                isNull,
                reason: '${entry.key} overflow di ${width.toInt()}dp x$scale',
              );
            }

            for (final MapEntry<String, Widget> entry
                in fullWidthSubjects.entries) {
              await tester.pumpWidget(_host(entry.value, locale: locale));
              await tester.pump();

              expect(
                tester.takeException(),
                isNull,
                reason: '${entry.key} overflow di ${width.toInt()}dp x$scale',
              );
            }
          },
        );
      }
    }
  }
}
