import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';
import 'package:mobile_barberstuff/features/history/presentation/pages/history_page.dart';
import 'package:mobile_barberstuff/features/history/presentation/widgets/review_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<double> _widths = <double>[320, 360, 390, 430];
const List<double> _scales = <double>[1.0, 1.3];

/// Jurnal kosong plus contoh isi, meniru booking yang pernah dibuat pengguna.
Future<BookingJournal> _journal({bool seeded = true}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final BookingJournal journal = BookingJournal(await AppCache.load());
  if (!seeded) return journal;

  final DateTime now = DateTime.now();

  const List<({String service, String store, int days, double? score})> rows =
      <({String service, String store, int days, double? score})>[
        (service: 'Cukur Jenggot', store: 'Kemang Raya', days: 2, score: null),
        (service: 'Cat Rambut', store: 'Pondok Indah', days: -6, score: null),
        (service: 'Hair Styling', store: 'Kemang Raya', days: -12, score: 4.8),
      ];

  for (int i = 0; i < rows.length; i++) {
    final row = rows[i];
    await journal.add(
      BookingRecord(
        id: 'bk-$i',
        qrCode: 'QR-$i',
        scheduledAt: now.add(Duration(days: row.days)),
        createdAt: now,
        storeId: 'store-$i',
        storeName: row.store,
        storeAddress: 'Jl. Uji No. $i',
        storePhone: '0800',
        capsterId: 'capster-$i',
        capsterName: 'Joni Akbar',
        lines: <BookingLine>[
          BookingLine(id: 'svc-$i', name: row.service, price: 95000),
        ],
        appServiceFee: 0,
        totalPrice: 95000,
        review: row.score == null
            ? null
            : const BookingReview(
                capster: 5,
                cashier: 5,
                store: 4,
                message: 'Rapi.',
              ),
      ),
    );
  }

  await journal.add(
    BookingRecord(
      id: 'bk-canceled',
      qrCode: 'QR-X',
      scheduledAt: now.subtract(const Duration(days: 20)),
      createdAt: now,
      storeId: 'store-x',
      storeName: 'Ciracas',
      storeAddress: 'Jl. Uji No. 9',
      storePhone: '0800',
      capsterId: 'capster-x',
      capsterName: 'Joni Akbar',
      lines: const <BookingLine>[
        BookingLine(id: 'svc-x', name: 'Hair Toner', price: 95000),
      ],
      appServiceFee: 0,
      totalPrice: 95000,
      canceled: true,
    ),
  );

  return journal;
}

Widget _host(HistoryRepository repo, Locale locale) {
  return ChangeNotifierProvider<HistoryRepository>.value(
    value: repo,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HistoryPage(),
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
      expect(BookingHistory.statusFromJson('progress'), BookingStatus.progress);
      expect(
        BookingHistory.statusFromJson('completed'),
        BookingStatus.completed,
      );
      expect(BookingHistory.statusFromJson('canceled'), BookingStatus.canceled);
      expect(BookingHistory.statusFromJson('apa pun'), BookingStatus.booked);

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

    test('draft ulasan menghitung rata-rata dan payload rating', () {
      const ReviewDraft draft = ReviewDraft(
        capster: 5,
        cashier: 4,
        store: 3,
        message: '  mantap  ',
      );

      expect(draft.isComplete, isTrue);
      expect(draft.average, closeTo(4.0, 0.001));

      final List<Map<String, dynamic>> payload = draft.toRatingPayload();
      expect(payload.length, 3);
      expect(payload[0]['type'], 'capster');
      expect(payload[1]['type'], 'staff');
      expect(payload[2]['type'], 'store');
      expect(payload[0]['message'], 'mantap');
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

      final HistoryRepository repo = HistoryRepository(await _journal());
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

    testWidgets('daftar kosong menampilkan pesan', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final BookingJournal journal = await _journal();
      final HistoryRepository repo = HistoryRepository(journal);
      addTearDown(repo.dispose);

      await tester.pumpWidget(_host(repo, const Locale('id')));
      await tester.pumpAndSettle();

      await journal.clear();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada booking di daftar ini.'), findsOneWidget);
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

            final HistoryRepository repo = HistoryRepository(await _journal());
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
