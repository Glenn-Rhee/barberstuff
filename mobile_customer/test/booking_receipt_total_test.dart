import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/pages/booking_receipt_page.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Respons `POST /booking/` untuk layanan 60.000. total_price dari backend
/// sudah termasuk biaya layanan 2.000.
BookingRecord _created() {
  return BookingRecord.fromResult(
    BookingResult.fromJson(<String, dynamic>{
      'id_booking': '8a1c2f00-0000-4000-8000-000000000001',
      'qr_code': 'bk8a1c2f00-0000-4000-8000-000000000001',
      'booking_date': '2026-09-24T12:30:00Z',
      'app_service_fee': 2000,
      'total_price': '62000',
      'store': <String, dynamic>{
        'id': 'store-1',
        'name': 'Barberstuff Pondok Gede',
        'address': 'Jl. Jatimakmur No.49C',
        'phone_number': '0800',
      },
      'capster': <String, dynamic>{'id': 'cap-1', 'name': 'Rihad Capster'},
      'service': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'svc-1',
          'name': 'Botak Licin',
          'price': '60000',
        },
      ],
    }),
    capsterId: 'cap-1',
    capsterName: 'Rihad Capster',
  );
}

void main() {
  setUpAll(initializeDateFormatting);

  test('total booking memakai total_price backend tanpa ditambah fee lagi', () {
    final BookingRecord record = _created();

    expect(record.totalPrice, 62000);
    expect(record.appServiceFee, 2000);
    expect(record.toHistory(DateTime(2026, 9, 1)).price, 62000);
  });

  testWidgets('e-receipt: layanan + biaya aplikasi = total harga', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BookingReceiptPage(record: _created()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(formatRupiah(60000)), findsOneWidget);
    expect(find.text(formatRupiah(2000)), findsOneWidget);
    expect(find.text(formatRupiah(62000)), findsOneWidget);
    expect(find.text(formatRupiah(64000)), findsNothing);
  });
}
