

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'support/fake_booking_repository.dart';

class _FakeStoreRepository extends StoreRepository {
  _FakeStoreRepository() : super(StoreRemoteDataSource(Dio()));

  @override
  Future<StoreDetail> getStoreDetail(String id) async {
    return StoreDetail(
      id: id,
      name: 'Barberstuff Jati Asih',
      phoneNumber: '081234567890',
      address: 'Jl. Jati Asih No. 20, Bekasi',
      bannerUrl: '',
      description:
          'Barberstuff menghadirkan pengalaman potong rambut dan penataan '
          'terbaik. Para barber kami adalah tenaga profesional bersertifikasi '
          'yang memadukan teknik klasik dengan suasana modern kelas atas.',
      storeType: 'lite',
      status: 'open',
      avgRating: 4.8,
      totalService: 18,
      totalCapster: 4,
      totalPackage: 5,
      coordinate: const StoreCoordinate(
        latitude: -6.260278,
        longitude: 106.813889,
      ),
      openHour: DateTime(2026, 1, 1, 8, 30),
      closeHour: DateTime(2026, 1, 1, 22, 0),
      reviews: const <StoreReview>[
        StoreReview(
          id: 'r1',
          message:
              'Pengalaman terbaik yang pernah saya rasakan dalam waktu lama. '
              'Barberstuff sangat profesional, bersih, dan para barbernya '
              'sangat ahli.',
          rating: 4,
          userName: 'Danielle Weygeles',
          userImageUrl: '',
          userTier: 'Klien Premium',
        ),
        StoreReview(
          id: 'r2',
          message:
              'Sudah berlangganan di sini selama 6 bulan. Hasil cukur fade-nya '
              'rapi, pembersihan jenggotnya bagus, dan stafnya sangat ramah.',
          rating: 4,
          userName: 'Alexander Osborn',
          userImageUrl: '',
          userTier: 'Pelanggan Setia',
        ),
      ],
    );
  }

  @override
  Future<List<CapsterItem>> getCapsters(String idStore) async {
    return List<CapsterItem>.generate(
      4,
      (int i) => const CapsterItem(
        id: 'c',
        name: 'Nathan',
        imageUrl: '',
        avgRating: 4.6,
        status: 'active',
      ),
    );
  }
}

class _ServiceBookingRepository extends FakeBookingRepository {
  _ServiceBookingRepository(super.cache);

  @override
  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  }) async {
    return List<ServiceItem>.generate(
      5,
      (int i) => ServiceItem(
        id: 's$i',
        name: type == ProductType.package
            ? 'Potong & Tata Rambut'
            : 'Potongan Rambut',
        price: type == ProductType.package ? 200000 : 200000,
        idStore: idStore,
        type: type,
        status: 'active',
        description: type == ProductType.package
            ? 'Paket Penawaran Spesial, berlaku hingga 15 Sep'
            : '18 types',
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    final FontLoader loader = FontLoader('Poppins');
    for (final String w in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final File f = File('assets/fonts/Poppins-$w.ttf');
      loader.addFont(
        Future<ByteData>.value(ByteData.sublistView(f.readAsBytesSync())),
      );
    }
    await loader.load();
  });

  Future<void> pump(WidgetTester tester, double width, Locale locale) async {
    final cache = await FakeBookingRepository.emptyCache();

    await tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<StoreRepository>.value(value: _FakeStoreRepository()),
          Provider<BookingRepository>.value(
            value: _ServiceBookingRepository(cache),
          ),
          Provider<LocationService>.value(value: LocationService(cache)),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoreDetailPage(args: StoreDetailArgs(storeId: 's1')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tab menampilkan konten yang sesuai', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pump(tester, 390, const Locale('id'));

    expect(find.text('Barberstuff Jati Asih'), findsOneWidget);
    expect(find.text('BUKA'), findsOneWidget);
    expect(find.textContaining('(2 reviews)'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);

    await tester.tap(find.text('Layanan'));
    await tester.pumpAndSettle();
    expect(find.text('Services Kami'), findsOneWidget);
    expect(find.text('Deskripsi'), findsNothing);

    await tester.tap(find.text('Paket'));
    await tester.pumpAndSettle();
    expect(find.text('Paket Kami'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsWidgets);

    await tester.tap(find.text('Ulasan'));
    await tester.pumpAndSettle();
    expect(find.text('Ulasan Pelanggan'), findsOneWidget);
    expect(find.text('Danielle Weygeles'), findsOneWidget);
    expect(find.text('4.8 / 5.0'), findsOneWidget);
  });

  for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
    for (final double width in <double>[320, 360, 390, 430]) {
      for (final double scale in <double>[1.0, 1.3]) {
        testWidgets('detail toko tanpa overflow: '
            '${locale.languageCode} ${width.toInt()}dp x$scale', (
          WidgetTester tester,
        ) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await pump(tester, width, locale);
          expect(tester.takeException(), isNull, reason: 'tab tentang kami');

          for (final String label in <String>['Paket', 'Packages']) {
            if (find.text(label).evaluate().isEmpty) continue;
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull, reason: 'tab paket');
        });
      }
    }
  }
}
