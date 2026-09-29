import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:mobile_barberstuff/features/history/data/datasources/history_remote_datasource.dart';
import 'package:mobile_barberstuff/features/history/data/models/customer_booking_model.dart';
import 'package:mobile_barberstuff/features/history/data/models/review_draft_model.dart';
import 'package:mobile_barberstuff/features/history/data/repositories/history_repository_impl.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/repositories/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/get_booking_history.dart';
import 'package:mobile_barberstuff/features/history/domain/usecases/submit_booking_review.dart';
import 'package:mobile_barberstuff/features/history/presentation/pages/history_page.dart';
import 'package:mobile_barberstuff/features/history/presentation/provider/customer_bookings_provider.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/review_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<double> _widths = <double>[320, 360, 390, 430];
const List<double> _scales = <double>[1.0, 1.3];

/// Meniru `GET /booking/customer` dan `POST /rating/` tanpa jaringan.
class _FakeRemote extends HistoryRemoteDataSource {
  _FakeRemote([Map<HistoryTab, List<Map<String, dynamic>>>? byTab])
    : byTab = byTab ?? <HistoryTab, List<Map<String, dynamic>>>{},
      super(Dio());

  Map<HistoryTab, List<Map<String, dynamic>>> byTab;
  ApiException? failure;
  final List<Map<String, dynamic>> ratings = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getBookings(HistoryTab tab) async {
    if (failure != null) throw failure!;
    return byTab[tab] ?? const <Map<String, dynamic>>[];
  }

  @override
  Future<void> createRating(Map<String, dynamic> body) async {
    ratings.add(body);
  }
}

/// Bentuk satu item `GET /booking/customer`. total_price desimal dikirim
/// backend sebagai string.
Map<String, dynamic> _serverBooking({
  required String id,
  required String service,
  required String store,
  required int days,
  Object price = '60000',
  Object total = '62000',
  Map<String, dynamic>? rating,
}) {
  return <String, dynamic>{
    'id': id,
    'service': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'svc-$id', 'name': service, 'price': price},
    ],
    'capster': <String, dynamic>{'id': 'cap-$id', 'name': 'Rihad Capster'},
    'store': <String, dynamic>{
      'id': 'store-$id',
      'name': store,
      'address': 'Jl. Uji',
      'phone_number': '0800',
    },
    'staff': <String, dynamic>{'id': 'staff-$id', 'name': 'Kasir'},
    'booking_date': DateTime.now()
        .add(Duration(days: days))
        .toUtc()
        .toIso8601String(),
    'total_price': total,
    'rating': rating,
  };
}

_FakeRemote _seededRemote() {
  return _FakeRemote(<HistoryTab, List<Map<String, dynamic>>>{
    HistoryTab.upcoming: <Map<String, dynamic>>[
      _serverBooking(
        id: 'bk-0',
        service: 'Cukur Jenggot',
        store: 'Kemang Raya',
        days: 2,
      ),
    ],
    HistoryTab.done: <Map<String, dynamic>>[
      _serverBooking(
        id: 'bk-1',
        service: 'Cat Rambut',
        store: 'Pondok Indah',
        days: -6,
      ),
      _serverBooking(
        id: 'bk-2',
        service: 'Hair Styling',
        store: 'Kemang Raya',
        days: -12,
        rating: <String, dynamic>{
          'avg_rating': 4.67,
          'capster_rating': 5,
          'staff_rating': 5,
          'store_rating': 4,
          'message': 'Rapi.',
        },
      ),
    ],
    HistoryTab.canceled: <Map<String, dynamic>>[
      _serverBooking(
        id: 'bk-canceled',
        service: 'Hair Toner',
        store: 'Ciracas',
        days: -20,
      ),
    ],
  });
}

Future<BookingLocalDataSource> _journal() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return BookingLocalDataSource(await AppCache.load());
}

BookingRecord _localRecord(String id, {String qr = 'QR-LOKAL'}) {
  final DateTime now = DateTime.now();
  return BookingRecord(
    id: id,
    qrCode: qr,
    scheduledAt: now.add(const Duration(days: 1)),
    createdAt: now,
    storeId: 'store-lama',
    storeName: 'Cabang Akun Lama',
    storeAddress: 'Jl. Lama',
    storePhone: '0800',
    capsterId: 'cap-lama',
    capsterName: 'Capster Lama',
    lines: const <BookingLine>[
      BookingLine(id: 'svc-lama', name: 'Botak Licin', price: 60000),
    ],
    appServiceFee: 2000,
    totalPrice: 62000,
  );
}

Future<CustomerBookingsProvider> _repo([
  _FakeRemote? remote,
  BookingLocalDataSource? journal,
]) async {
  final HistoryRepository repo = HistoryRepositoryImpl(
    remote ?? _seededRemote(),
    journal ?? await _journal(),
  );
  return CustomerBookingsProvider(
    GetBookingHistory(repo),
    SubmitBookingReview(repo),
  );
}

Widget _host(CustomerBookingsProvider repo, Locale locale) {
  return ChangeNotifierProvider<CustomerBookingsProvider>.value(
    value: repo,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HistoryPage(),
      onGenerateRoute: AppRoute.onGenerateRoute,
    ),
  );
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

  group('model', () {
    test('status backend dipetakan ke tab yang benar', () {
      expect(
        CustomerBookingModel.statusFromJson('progress'),
        BookingStatus.progress,
      );
      expect(
        CustomerBookingModel.statusFromJson('completed'),
        BookingStatus.completed,
      );
      expect(
        CustomerBookingModel.statusFromJson('canceled'),
        BookingStatus.canceled,
      );
      expect(
        CustomerBookingModel.statusFromJson('apa pun'),
        BookingStatus.booked,
      );

      BookingHistory build(BookingStatus s) => BookingHistory(
        id: 'x',
        serviceName: 'Potong Rambut',
        storeName: 'Kemang',
        date: DateTime(2026, 5, 8),
        price: 95000,
        status: s,
      );

      expect(build(BookingStatus.booked).tab, HistoryTab.upcoming);
      expect(build(BookingStatus.progress).tab, HistoryTab.upcoming);
      expect(build(BookingStatus.completed).tab, HistoryTab.done);
      expect(build(BookingStatus.canceled).tab, HistoryTab.canceled);
    });

    test('draft ulasan menghitung rata-rata dan body POST /rating/', () {
      const ReviewDraft draft = ReviewDraft(
        capster: 5,
        cashier: 4,
        store: 3,
        message: '  mantap  ',
      );

      expect(draft.isComplete, isTrue);
      expect(draft.average, closeTo(4.0, 0.001));

      expect(
        draft.toRatingBody(
          bookingId: 'bk-1',
          capsterId: 'cap-1',
          staffId: 'staff-1',
          storeId: 'store-1',
        ),
        <String, dynamic>{
          'id_booking': 'bk-1',
          'rating': <String, dynamic>{
            'capster': <String, dynamic>{'id': 'cap-1', 'score': 5},
            'staff': <String, dynamic>{'id': 'staff-1', 'score': 4},
            'store': <String, dynamic>{
              'id': 'store-1',
              'score': 3,
              'message': 'mantap',
            },
          },
        },
      );
    });

    test('item server: total dipakai apa adanya, rating dan QR terbaca', () {
      final BookingRecord record = CustomerBookingModel.fromJson(
        _serverBooking(
          id: 'abc',
          service: 'Botak Licin',
          store: 'Pondok Gede',
          days: 1,
          rating: <String, dynamic>{
            'capster_rating': 5,
            'staff_rating': 4,
            'store_rating': 3,
            'message': 'ok',
          },
        ),
        status: BookingStatus.completed,
      );

      expect(record.totalPrice, 62000);
      expect(record.lines.single.price, 60000);
      expect(BookingHistory.fromRecord(record, DateTime.now()).price, 62000);
      expect(record.staffId, 'staff-abc');
      expect(record.qrCode, 'bkabc');
      expect(record.appServiceFee, 0);
      expect(record.review?.cashier, 4);
      expect(record.statusAt(DateTime.now()), BookingStatus.completed);

      final BookingRecord withLocal = CustomerBookingModel.fromJson(
        _serverBooking(id: 'abc', service: 'x', store: 'y', days: 1),
        status: BookingStatus.booked,
        local: _localRecord('abc', qr: 'QR-ASLI'),
      );
      expect(withLocal.qrCode, 'QR-ASLI');
      expect(withLocal.appServiceFee, 2000);
      expect(withLocal.totalPrice, 62000);
    });

    test('draft belum lengkap kalau ada bintang yang kosong', () {
      const ReviewDraft draft = ReviewDraft(
        capster: 5,
        cashier: 0,
        store: 3,
        message: '',
      );
      expect(draft.isComplete, isFalse);
    });
  });

  group('halaman riwayat', () {
    testWidgets('tab menyaring daftar sesuai status', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final CustomerBookingsProvider repo = await _repo();
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      expect(find.text('PROGRESS'), findsWidgets);
      expect(find.text('DONE'), findsNothing);

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.text('DONE'), findsWidgets);
      expect(find.text('Belum diulas'), findsWidgets);
      expect(find.textContaining('Ulasanmu'), findsWidgets);

      await tester.tap(find.text('Dibatalkan'));
      await tester.pumpAndSettle();
      expect(find.text('CANCEL'), findsWidgets);
      expect(find.text('DONE'), findsNothing);
    });

    testWidgets('kartu membuka detail booking, tombol ulasan tetap terpisah', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final CustomerBookingsProvider repo = await _repo();
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cukur Jenggot'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingDetailPage), findsOneWidget);
      Finder inDetail(String text) => find.descendant(
        of: find.byType(BookingDetailPage),
        matching: find.text(text),
      );
      expect(inDetail('Kemang Raya'), findsOneWidget);
      expect(inDetail('Rihad Capster'), findsOneWidget);
      // Booking akan datang: bukti pesanan (barcode) bisa dibuka.
      expect(inDetail('Lihat Bukti Pesanan'), findsOneWidget);

      Navigator.of(tester.element(find.byType(BookingDetailPage))).pop();
      await tester.pumpAndSettle();

      // Booking batal tidak punya tombol bukti pesanan.
      await tester.tap(find.text('Dibatalkan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hair Toner'));
      await tester.pumpAndSettle();
      expect(inDetail('Ciracas'), findsOneWidget);
      expect(inDetail('Lihat Bukti Pesanan'), findsNothing);

      Navigator.of(tester.element(find.byType(BookingDetailPage))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beri Ulasan').first);
      await tester.pumpAndSettle();
      expect(find.byType(ReviewSheet), findsOneWidget);
      expect(find.byType(BookingDetailPage), findsNothing);
    });

    testWidgets('daftar kosong menampilkan pesan', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final CustomerBookingsProvider repo = await _repo(_FakeRemote());
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada booking di daftar ini.'), findsOneWidget);
    });

    testWidgets('akun baru tidak melihat booking yang tersimpan di perangkat', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Jurnal perangkat masih berisi booking akun sebelumnya.
      final BookingLocalDataSource journal = await _journal();
      await journal.add(_localRecord('bk-akun-lama'));

      // Server bilang akun ini belum pernah booking.
      final CustomerBookingsProvider repo = await _repo(_FakeRemote(), journal);
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cabang Akun Lama'), findsNothing);
      expect(find.text('Belum ada booking di daftar ini.'), findsOneWidget);
    });

    testWidgets('gagal memuat menampilkan pesan dari server', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final _FakeRemote remote = _FakeRemote()
        ..failure = const ApiException(
          ApiErrorType.server,
          rawMessage: 'Gagal mengambil data booking',
        );
      final CustomerBookingsProvider repo = await _repo(remote);
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      expect(find.text('Gagal mengambil data booking'), findsOneWidget);
    });

    for (final Locale locale in <Locale>[Locale('id'), Locale('en')]) {
      for (final double width in _widths) {
        for (final double scale in _scales) {
          testWidgets('riwayat tanpa overflow: '
              '${locale.languageCode} ${width.toInt()}dp x$scale', (
            WidgetTester tester,
          ) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );

            final CustomerBookingsProvider repo = await _repo();
            addTearDown(repo.dispose);

            await tester.pumpWidget(_host(repo, locale));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'tab akan datang');

            for (final String label in <String>['Selesai', 'Completed']) {
              if (find.text(label).evaluate().isEmpty) continue;
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
            }
            expect(tester.takeException(), isNull, reason: 'tab selesai');
          });
        }
      }
    }
  });

  group('booking akun', () {
    test('ulasan dikirim ke server lalu tampil sebagai sudah diulas', () async {
      final _FakeRemote remote = _seededRemote();
      final CustomerBookingsProvider repo = await _repo(remote);
      addTearDown(repo.dispose);
      await repo.refresh();

      await repo.submitReview(
        'bk-1',
        const ReviewDraft(capster: 5, cashier: 4, store: 5, message: 'Mantap'),
      );

      expect(remote.ratings.single['id_booking'], 'bk-1');
      expect(
        (remote.ratings.single['rating'] as Map<String, dynamic>)['staff'],
        <String, dynamic>{'id': 'staff-bk-1', 'score': 4},
      );
      expect(repo.byId('bk-1')?.isReviewed, isTrue);
    });

    test('reset saat logout mengosongkan data akun sebelumnya', () async {
      final CustomerBookingsProvider repo = await _repo();
      addTearDown(repo.dispose);
      await repo.refresh();
      expect(repo.records, isNotEmpty);
      expect(repo.upcoming?.id, 'bk-0');
      expect(repo.completed.map((BookingRecord r) => r.id), <String>[
        'bk-1',
        'bk-2',
      ]);

      repo.reset();

      expect(repo.records, isEmpty);
      expect(repo.upcoming, isNull);
      expect(repo.isLoaded, isFalse);
    });
  });

  group('sheet ulasan', () {
    testWidgets('punya 15 bintang dan bisa dipilih', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ReviewSheet()),
        ),
      );
      await tester.pumpAndSettle();

      List<Element> starsOf(String asset) => find
          .byType(Image)
          .evaluate()
          .where(
            (Element e) =>
                ((e.widget as Image).image as AssetImage).assetName == asset,
          )
          .toList();

      expect(
        starsOf(AppAssets.starHistoryEmpty).length +
            starsOf(AppAssets.starHistoryFilled).length,
        15,
      );
      expect(starsOf(AppAssets.starHistoryFilled), isEmpty);

      await tester.tap(
        find.byWidget(starsOf(AppAssets.starHistoryEmpty)[2].widget),
      );
      await tester.pumpAndSettle();

      expect(starsOf(AppAssets.starHistoryFilled).length, 3);
      expect(tester.takeException(), isNull);
    });
  });
}
