import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablet_dashboard/app/app.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

import 'escpos_decoder.dart';
import 'fake_api.dart';

const _channel = MethodChannel('barberstuff/bluetooth_printer');

const _openSession = CashSession(
  id: 'CS-1',
  openingBalance: 100000,
  incomeCash: 0,
  incomeCashless: 0,
  outcome: 0,
  transactions: [],
);

void main() {
  late FakeApi api;
  late List<MethodCall> printerCalls;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = FakeApi();
    printerCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  List<String> printed() {
    final write = printerCalls.lastWhere((c) => c.method == 'write');
    return decodeEscPos(
      (write.arguments as Map)['bytes'] as Uint8List,
    ).map((l) => l.text).toList();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    // Tablet 1280x800 dp landscape
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TabletDashboardApp(
        authApi: api,
        catalogApi: api,
        bookingApi: api,
        cashSessionApi: api,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signIn(
    WidgetTester tester, {
    String password = FakeApi.password,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'nama@barberstuff.id'),
      'staff@barberstuff.id',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '••••••••'),
      password,
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
  }

  Future<void> openOrder(WidgetTester tester) async {
    await tester.tap(find.text('Kasir').first);
    await tester.pumpAndSettle();
  }

  testWidgets('login tolak password salah, masuk kalau benar', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Masuk ke Dashboard'), findsOneWidget);

    await signIn(tester, password: 'salah');
    expect(find.text('Password salah'), findsOneWidget);

    await signIn(tester);
    expect(find.text('Dashboard Kasir > Ringkasan'), findsOneWidget);
    expect(find.text('Selamat Datang, Wibawa!'), findsOneWidget);
    expect(find.text('Wibawa Mukti'), findsOneWidget); // sidebar
    expect(
      api.calls,
      containsAll([
        'login',
        'profile',
        'capsters',
        'cashSession',
        'bookings:all',
      ]),
    );
  });

  testWidgets('admin masuk ke dashboard admin dan tetap bisa buka kasir', (
    tester,
  ) async {
    api.staff = FakeApi.staffAs('admin');
    await pumpApp(tester);
    await signIn(tester);

    expect(find.text('Dashboard Admin > Ringkasan'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Administrator'), findsNWidgets(2)); // sidebar + kartu

    await openOrder(tester);
    expect(find.text('Pesanan Langsung'), findsOneWidget);
    expect(find.text('Classic Hair Cut'), findsOneWidget);
  });

  testWidgets('mitra masuk ke dashboard mitra', (tester) async {
    api.staff = FakeApi.staffAs('mitra');
    await pumpApp(tester);
    await signIn(tester);

    expect(find.text('Dashboard Mitra > Ringkasan'), findsOneWidget);
    expect(find.text('Mitra Barberstuff'), findsNWidgets(2));
  });

  testWidgets('role di luar kasir/admin/mitra ditolak', (tester) async {
    api.staff = FakeApi.staffAs('customer');
    await pumpApp(tester);
    await signIn(tester);

    expect(find.text(SessionController.noAccessMessage), findsOneWidget);
    expect(find.text('Masuk ke Dashboard'), findsOneWidget);
  });

  testWidgets('angka dashboard kosong sampai shift dibuka', (tester) async {
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

  testWidgets('tutup shift yang ditolak cuma muncul sebagai toast', (
    tester,
  ) async {
    api.session = const CashSession(
      id: 'CS-1',
      openingBalance: 20000,
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
    expect(
      find.textContaining(
        'hanya bisa ditutup setelah toko lewat jam operasional',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.widgetWithText(TextField, '0'), '20000');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Tutup Shift'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Belum bisa tutup kas'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing); // data dashboard tetap aman
    expect(find.text('Shift Buka'), findsOneWidget); // shift tetap buka
    expect(api.closedWith, isNull);
  });

  testWidgets('pesanan langsung: katalog dari API, bayar, dan cetak', (
    tester,
  ) async {
    api.session = _openSession;
    await pumpApp(tester);
    await signIn(tester);
    await openOrder(tester);

    expect(find.text('Classic Hair Cut'), findsOneWidget);
    await tester.tap(find.text('+ Tambah').first);
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nama Pelanggan (opsional)'),
      'Hendra',
    );
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

  testWidgets('bayar booking pakai nominal dari server', (tester) async {
    api.session = _openSession;
    api.bookingList = [
      fakeBooking(
        price: 65000,
        discount: 15000,
        status: BookingStatus.progress,
      ),
    ];
    await pumpApp(tester);
    await signIn(tester);
    await openOrder(tester);
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

  testWidgets('booking yang belum check-in minta scan QR dulu', (
    tester,
  ) async {
    api.session = _openSession;
    api.bookingList = [fakeBooking()];
    await pumpApp(tester);
    await signIn(tester);
    await openOrder(tester);
    await tester.tap(find.text('Dari Reservasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iqbal Apriand'));
    await tester.pumpAndSettle();

    expect(find.textContaining('belum check-in'), findsOneWidget);
    expect(find.text('Bayar & Cetak Struk'), findsNothing);
  });

  testWidgets('booking selesai hanya bisa cetak ulang', (tester) async {
    api.bookingList = [fakeBooking(status: BookingStatus.completed)];
    await pumpApp(tester);
    await signIn(tester);
    await openOrder(tester);
    await tester.tap(find.text('Dari Reservasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iqbal Apriand'));
    await tester.pumpAndSettle();

    expect(find.text('Booking selesai'), findsOneWidget);
    expect(find.text('Bayar & Cetak Struk'), findsNothing);

    await tester.tap(find.text('Cetak Ulang Struk'));
    await tester.pumpAndSettle();
    expect(printed(), contains(row('Pelanggan', 'Iqbal Apriand')));
    expect(api.lastSale, isNull); // cetak ulang tidak boleh buat transaksi
  });

  testWidgets('pembayaran diblokir selama shift tutup', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    await openOrder(tester);

    await tester.tap(find.text('+ Tambah').first);
    await tester.pump();

    expect(find.textContaining('Shift kasir belum dibuka'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Bayar & Cetak Struk'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('sidebar bisa diperkecil jadi ikon dan dibesarkan lagi', (
    tester,
  ) async {
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

  testWidgets('keluar balik ke layar login', (tester) async {
    await pumpApp(tester);
    await signIn(tester);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Dashboard'), findsOneWidget);
  });
}
