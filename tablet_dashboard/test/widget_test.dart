import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablet_dashboard/features/dashboard/domain/cash_session.dart';
import 'package:tablet_dashboard/features/reservation/domain/booking.dart';
import 'package:tablet_dashboard/main.dart';

import 'escpos_decoder.dart';
import 'fake_api.dart';

const _channel = MethodChannel('barberstuff/bluetooth_printer');

void main() {
  late FakeApi api;
  late List<MethodCall> printerCalls;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = FakeApi();
    printerCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
      printerCalls.add(call);
      return switch (call.method) {
        'bondedDevices' => [
          {'name': 'RPP210A', 'address': 'DC:0D:30:AA:BB:CC'},
        ],
        'connect' || 'isConnected' || 'write' => true,
        _ => null,
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
  });

  List<String> printed() {
    final write = printerCalls.lastWhere((c) => c.method == 'write');
    return decodeEscPos((write.arguments as Map)['bytes'] as Uint8List).map((l) => l.text).toList();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2560, 1600); // Medium_Tablet in landscape
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(TabletApp(api: api));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester, {String password = FakeApi.password}) async {
    await tester.enterText(find.widgetWithText(TextField, 'nama@barberstuff.id'), 'kasir@barberstuff.id');
    await tester.enterText(find.widgetWithText(TextField, '••••••••'), password);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
  }

  Future<void> openKasir(WidgetTester tester) async {
    // "Kasir" is also the role label under the cashier's name in the sidebar.
    await tester.tap(find.text('Kasir').first);
    await tester.pumpAndSettle();
  }

  testWidgets('login rejects a wrong password and signs in on success', (tester) async {
    await pumpApp(tester);
    expect(find.text('Masuk ke Kasir'), findsOneWidget);

    await signIn(tester, password: 'salah');
    expect(find.text('Password salah'), findsOneWidget);

    await signIn(tester);
    expect(find.text('Selamat Datang, Wibawa!'), findsOneWidget);
    expect(find.text('Wibawa Mukti'), findsOneWidget); // sidebar
    expect(api.calls, containsAll(['login', 'profile', 'capsters', 'cashSession', 'bookings:all']));
  });

  testWidgets('dashboard hides numbers until the shift is open, then shows the session', (tester) async {
    await pumpApp(tester);
    await signIn(tester);

    expect(find.text('Shift Tutup'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(4));
    expect(find.text('Shift belum dibuka'), findsNWidgets(4));

    await tester.tap(find.text('Buka Shift Kasir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '0'), '200000');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Buka Shift'));
    await tester.pumpAndSettle();

    expect(api.openedWith, 200000);
    expect(find.text('Shift Buka'), findsOneWidget);
    expect(find.text('Rp 200.000'), findsWidgets); // kas di laci + modal awal
  });

  testWidgets('a refused shift close is reported without breaking the dashboard', (tester) async {
    api.session = const CashSession(
      id: 'CS-1',
      saldoBegin: 20000,
      incomeCash: 0,
      incomeCashless: 0,
      outcome: 0,
      transactions: [],
    );
    api.closeError = 'Toko masih dalam operasional tidak dapat menutup kas.';
    await pumpApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Tutup Shift Kasir'));
    await tester.pumpAndSettle();
    expect(find.textContaining('hanya bisa ditutup setelah toko lewat jam operasional'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '0'), '20000');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Tutup Shift'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Belum bisa tutup kas'), findsOneWidget); // toast, not a banner
    expect(find.text('Coba lagi'), findsNothing); // the dashboard data is fine
    expect(find.text('Shift Buka'), findsOneWidget); // till stays open
    expect(api.closedWith, isNull);
  });

  testWidgets('walk-in order: catalog from the API, pay and print', (tester) async {
    api.session = const CashSession(
      id: 'CS-1',
      saldoBegin: 100000,
      incomeCash: 0,
      incomeCashless: 0,
      outcome: 0,
      transactions: [],
    );
    await pumpApp(tester);
    await signIn(tester);
    await openKasir(tester);

    expect(find.text('Classic Hair Cut'), findsOneWidget);
    await tester.tap(find.text('+ Tambah').first);
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, 'Nama Pelanggan (opsional)'), 'Hendra');
    await tester.tap(find.text('Pilih capster'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wahyu').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bayar & Cetak Struk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50.000'));
    await tester.pump();
    await tester.tap(find.text('Konfirmasi & Cetak'));
    await tester.pumpAndSettle();

    expect(api.createdBookingCapster, 'CAP-1');
    expect(api.createdBookingServices, ['SVC-1']);
    expect(api.lastSale?.amount, 45000);
    expect(api.lastSale?.payment, PaymentType.cash);
    expect(api.lastSale?.bookingId, 'bk-0123456789');

    final text = printed();
    expect(text, contains(row('Pelanggan', 'Hendra')));
    expect(text, contains(row('Capster', 'Wahyu')));
    expect(text, contains('Classic Hair Cut'));
    expect(text, contains(row('TOTAL', 'Rp 45.000')));
    expect(text, contains(row('Kembali', 'Rp 5.000')));
    expect(find.textContaining('berhasil'), findsOneWidget);
  });

  testWidgets('paying a booking uses the amounts the server sent', (tester) async {
    api.session = const CashSession(
      id: 'CS-1',
      saldoBegin: 100000,
      incomeCash: 0,
      incomeCashless: 0,
      outcome: 0,
      transactions: [],
    );
    api.bookingList = [fakeBooking(price: 65000, discount: 15000)];
    await pumpApp(tester);
    await signIn(tester);
    await openKasir(tester);
    await tester.tap(find.text('Dari Reservasi'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih booking'), findsOneWidget);
    await tester.tap(find.text('Iqbal Apriand'));
    await tester.pumpAndSettle();
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('1.250 poin'), findsOneWidget);
    expect(find.text('-Rp 15.000'), findsOneWidget);

    await tester.tap(find.text('QRIS'));
    await tester.pump();
    await tester.tap(find.text('Bayar & Cetak Struk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konfirmasi & Cetak'));
    await tester.pumpAndSettle();

    expect(api.lastSale?.amount, 50000);
    expect(api.lastSale?.payment, PaymentType.cashless);
    expect(api.lastSale?.bookingId, 'BK-1');

    final text = printed();
    expect(text, contains(row('Pelanggan', 'Iqbal Apriand')));
    expect(text, contains(row('Diskon', '-Rp 15.000')));
    expect(text, contains(row('TOTAL', 'Rp 50.000')));
  });

  testWidgets('completed bookings can only be reprinted', (tester) async {
    api.bookingList = [fakeBooking(status: BookingStatus.completed)];
    await pumpApp(tester);
    await signIn(tester);
    await openKasir(tester);
    await tester.tap(find.text('Dari Reservasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iqbal Apriand'));
    await tester.pumpAndSettle();

    expect(find.text('Booking selesai'), findsOneWidget);
    expect(find.text('Bayar & Cetak Struk'), findsNothing);

    await tester.tap(find.text('Cetak Ulang Struk'));
    await tester.pumpAndSettle();
    expect(printed(), contains(row('Pelanggan', 'Iqbal Apriand')));
    expect(api.lastSale, isNull); // reprint must not create a transaction
  });

  testWidgets('payment is blocked while the shift is closed', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    await openKasir(tester);

    await tester.tap(find.text('+ Tambah').first);
    await tester.pump();

    expect(find.textContaining('Shift kasir belum dibuka'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Bayar & Cetak Struk')).onPressed, isNull);
  });

  testWidgets('sidebar collapses to icons and back', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    expect(find.text('Konfigurasi'), findsOneWidget);

    await tester.tap(find.byTooltip('Perkecil menu'));
    await tester.pumpAndSettle();
    expect(find.text('Konfigurasi'), findsNothing);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    await tester.tap(find.byTooltip('Perbesar menu'));
    await tester.pumpAndSettle();
    expect(find.text('Konfigurasi'), findsOneWidget);
  });

  testWidgets('signing out returns to the login screen', (tester) async {
    await pumpApp(tester);
    await signIn(tester);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Kasir'), findsOneWidget);
  });
}
