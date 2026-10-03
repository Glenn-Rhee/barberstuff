import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablet_dashboard/app/app.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

import 'escpos_decoder.dart';
import 'fake_api.dart';

const _channel = MethodChannel('barberstuff/bluetooth_printer');

// Cari ikon dari assets berdasarkan path-nya
Finder _assetIcon(String asset) =>
    find.byWidgetPredicate((w) => w is AppIcon && w.asset == asset);

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
    return decodeEscPos((write.arguments as Map)['bytes'] as Uint8List)
        .map((l) => l.text)
        .toList();
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
        storeApi: api,
        customerApi: api,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signIn(
    WidgetTester tester, {
    String password = FakeApi.defaultPassword,
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

  // Centang "Saya memastikan data sudah benar" lalu tekan tombol simpan
  Future<void> confirmAndSubmit(WidgetTester tester, String label) async {
    await tester.tap(find.text('Saya memastikan data sudah benar'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  group('login', () {
    testWidgets('tolak password salah, masuk kalau benar', (tester) async {
      await pumpApp(tester);
      expect(find.text('Masuk ke Dashboard'), findsOneWidget);

      await signIn(tester, password: 'salah');
      expect(find.text('Password salah'), findsOneWidget);

      await signIn(tester);
      expect(find.text('Dashboard > Ringkasan'), findsOneWidget);
      expect(find.text('Selamat Datang, Wibawa!'), findsOneWidget);
      expect(find.text('Wibawa Mukti'), findsOneWidget); // sidebar
      expect(
        api.calls,
        containsAll([
          'login',
          'profile',
          'cashHistory',
          'capsters',
          'cashSession',
          'bookings:all',
        ]),
      );
    });

    testWidgets('reset password tanpa verifikasi lalu masuk pakai yang baru', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Reset password?'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Password'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'nama@barberstuff.id'),
        'staff@barberstuff.id',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '••••••••'),
        FakeApi.defaultPassword,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Minimal 5 karakter'),
        'baru123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Ketik ulang password baru'),
        'baru123',
      );
      await tester.tap(find.text('Simpan Password Baru'));
      await tester.pumpAndSettle();

      expect(api.calls, contains('updateAccount:STF-1'));
      expect(find.textContaining('Password berhasil diganti'), findsOneWidget);

      await signIn(tester, password: 'baru123');
      expect(find.text('Dashboard > Ringkasan'), findsOneWidget);
    });

    testWidgets('reset password tolak konfirmasi yang beda', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Reset password?'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'nama@barberstuff.id'),
        'staff@barberstuff.id',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '••••••••'),
        FakeApi.defaultPassword,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Minimal 5 karakter'),
        'baru123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Ketik ulang password baru'),
        'beda123',
      );
      await tester.tap(find.text('Simpan Password Baru'));
      await tester.pumpAndSettle();

      expect(find.text('Ulangi password baru belum sama'), findsOneWidget);
      expect(api.calls, isNot(contains('updateAccount:STF-1')));
    });

    testWidgets('role di luar kasir/admin/mitra ditolak', (tester) async {
      api.staff = FakeApi.staffAs('customer');
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text(SessionController.noAccessMessage), findsOneWidget);
      expect(find.text('Masuk ke Dashboard'), findsOneWidget);
    });
  });

  group('role', () {
    testWidgets('kasir: lokasi toko dari akun dan terkunci', (tester) async {
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('Barberstuff Cikutra'), findsOneWidget);
      expect(_assetIcon(AppAsset.lockIcon), findsOneWidget);
      expect(api.calls, isNot(contains('stores')));
    });

    testWidgets('admin: bisa ganti cabang, shift khusus kasir', (tester) async {
      api.staff = FakeApi.staffAs('admin');
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('Dashboard Admin > Ringkasan'), findsOneWidget);
      expect(find.text('Administrator'), findsNWidgets(2)); // sidebar + kartu
      expect(api.calls, isNot(contains('cashSession')));
      expect(
        find.text('Shift dan pembayaran hanya bisa dikelola akun kasir.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Barberstuff Cikutra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barberstuff Depok').last);
      await tester.pumpAndSettle();
      expect(find.text('Barberstuff Depok'), findsOneWidget);
    });

    testWidgets('mitra masuk ke dashboard mitra', (tester) async {
      api.staff = FakeApi.staffAs('mitra');
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('Dashboard Mitra > Ringkasan'), findsOneWidget);
      expect(find.text('Mitra Barberstuff'), findsNWidgets(2));
      expect(api.calls, contains('store:STORE-1'));
    });
  });

  group('dashboard kasir', () {
    testWidgets('angka shift kosong sampai saldo awal diisi', (tester) async {
      api.bookingList = [fakeBooking()];
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('—'), findsNWidgets(2)); // transaksi + penjualan
      expect(find.text('Shift belum dibuka'), findsNWidgets(2));
      expect(
        find.text('Iqbal Apriand'),
        findsOneWidget,
      ); // reservasi berikutnya

      await tester.tap(find.text('Buka Shift Kasir'));
      await tester.pumpAndSettle();
      expect(find.text('Saldo Awal'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '0'), '200000');
      await tester.pump();
      expect(find.text('200.000'), findsOneWidget);
      await confirmAndSubmit(tester, 'Simpan');

      expect(api.openedWith, 200000);
      expect(find.text('Shift Sedang Berjalan:'), findsOneWidget);
      expect(find.text('Tutup Shift Kasir'), findsOneWidget);
    });

    testWidgets('tutup shift ditolak backend, dialog tetap terbuka', (
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
        find.textContaining('setelah toko lewat jam operasional'),
        findsOneWidget,
      );

      await tester.enterText(find.widgetWithText(TextField, '0'), '20000');
      await tester.pump();
      await confirmAndSubmit(tester, 'Tutup Shift');

      expect(find.textContaining('Belum bisa tutup kas'), findsOneWidget);
      expect(api.closedWith, isNull);
    });

    testWidgets('aksi cepat: catat kas keluar tersimpan ke shift', (
      tester,
    ) async {
      api.session = _openSession;
      await pumpApp(tester);
      await signIn(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Catat Kas Keluar'));
      await tester.pumpAndSettle();
      expect(find.text('Catat Kas'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget); // kategori awal

      await tester.enterText(find.widgetWithText(TextField, '0'), '75000');
      await tester.enterText(
        find.widgetWithText(TextField, 'Contoh: beli air mineral dan tisu'),
        'Beli air mineral dan tisu',
      );
      await tester.pump();
      await confirmAndSubmit(tester, 'Simpan');

      expect(api.lastOutcome?.amount, 75000);
      expect(api.lastOutcome?.title, 'Beli air mineral dan tisu');
      expect(
        find.textContaining('Pengeluaran Rp 75.000 dicatat'),
        findsOneWidget,
      );
    });

    testWidgets('aksi cepat: absensi mengubah karyawan bertugas dan kasir', (
      tester,
    ) async {
      api.session = _openSession;
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('0 Hadir'), findsNWidgets(2)); // statistik + kartu
      await tester.tap(find.widgetWithText(OutlinedButton, 'Absensi Karyawan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Absensi Karyawan'), findsWidgets);

      // Wahyu hadir, Rizal tidak hadir
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hadir').first);
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Tidak Hadir').last);
      await tester.pump();
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(find.text('1 Hadir'), findsNWidgets(2));
      expect(find.textContaining('1 karyawan off'), findsOneWidget);

      // Capster yang tidak hadir tidak bisa dipilih di Kasir
      await openOrder(tester);
      await tester.ensureVisible(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      expect(find.text('Wahyu'), findsWidgets);
      expect(find.text('Rizal'), findsNothing);
    });

    testWidgets('scan barcode: kode manual check-in lalu buka booking', (
      tester,
    ) async {
      api.bookingList = [fakeBooking()];
      await pumpApp(tester);
      await signIn(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Scan Barcode'));
      await tester.pumpAndSettle();
      expect(find.text('Scan QR Booking'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'bk…'), 'bkBK-1');
      await tester.tap(find.widgetWithText(FilledButton, 'Check-in'));
      await tester.pumpAndSettle();

      expect(api.calls, contains('checkIn:bkBK-1'));
      expect(find.text('Keranjang'), findsOneWidget); // panel booking terpilih
      expect(find.textContaining('Check-in berhasil'), findsOneWidget);
    });
  });

  group('kasir', () {
    // Isi pelanggan baru (nama + no HP) dan pilih capster Wahyu
    Future<void> fillWalkIn(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Nama Pelanggan'),
        'Hendra',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nomor Telepon'),
        '089912345678',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wahyu').last);
      await tester.pumpAndSettle();
    }

    testWidgets('keranjang: cuma 1 service atau 1 paket, tanpa jumlah', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      expect(find.text('Classic Hair Cut'), findsOneWidget);
      expect(find.text('Paket Ayah & Anak'), findsOneWidget); // filter Semua

      await tester.tap(find.text('+ Tambah').at(0));
      await tester.pump();
      expect(find.text('Dipilih'), findsOneWidget);
      expect(find.text('Rp 45.000'), findsWidgets);

      // Service kedua menggantikan yang pertama
      await tester.tap(find.text('+ Tambah').at(0));
      await tester.pump();
      expect(
        find.textContaining('keranjang diganti Gentlement Grooming'),
        findsOneWidget,
      );
      expect(find.text('Dipilih'), findsOneWidget);
      expect(find.text('Rp 65.000'), findsWidgets);
      expect(find.text('Rp 110.000'), findsNothing);

      // Paket juga menggantikan
      await tester.tap(find.text('+ Tambah').last);
      await tester.pump();
      expect(find.text('Dipilih'), findsOneWidget);
      expect(find.text('Rp 85.000'), findsWidgets);

      // Tap lagi = keluarkan dari keranjang
      await tester.tap(find.text('Dipilih'));
      await tester.pump();
      expect(find.text('Dipilih'), findsNothing);
    });

    testWidgets('pesanan langsung: buat, check-in, bayar, dan cetak', (
      tester,
    ) async {
      api.session = _openSession;
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      await tester.tap(find.text('+ Tambah').first);
      await tester.pump();
      await fillWalkIn(tester);

      await tester.tap(find.text('Bayar & Cetak Struk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50.000'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi & Cetak'));
      await tester.pumpAndSettle();

      expect(api.createdBookingCapster, 'CAP-1');
      expect(api.createdBookingServices, ['SVC-1']);
      expect(api.calls, contains('checkIn:bkBK-NEW-1'));
      expect(api.lastSale?.payment, PaymentType.cash);
      expect(api.lastSale?.bookingId, 'BK-NEW-1');
      expect(api.bookingList.single.status, BookingStatus.completed);

      // Pelanggan tanpa aplikasi masuk histori sebagai reguler
      expect(api.customerList.first.name, 'Hendra');
      expect(api.customerList.first.isMember, isFalse);

      final text = printed();
      expect(text, contains(row('Pelanggan', 'Hendra')));
      expect(text, contains(row('Capster', 'Wahyu')));
      expect(text, contains(row('TOTAL', 'Rp 45.000')));
      expect(text, contains(row('Kembali', 'Rp 5.000')));
      expect(find.textContaining('berhasil'), findsOneWidget);
    });

    testWidgets('simpan pesanan: masuk Dari Reservasi status progress', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      await tester.tap(find.text('+ Tambah').first);
      await tester.pump();
      await fillWalkIn(tester);
      await tester.ensureVisible(find.text('Simpan Pesanan'));
      await tester.tap(find.text('Simpan Pesanan'));
      await tester.pumpAndSettle();

      expect(api.bookingList.single.status, BookingStatus.progress);
      expect(api.lastSale, isNull);
      expect(find.textContaining('Pesanan Hendra tersimpan'), findsOneWidget);

      await tester.tap(find.text('Dari Reservasi'));
      await tester.pumpAndSettle();
      expect(find.text('Hendra'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('pesanan langsung wajib nama + no HP pelanggan baru', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      await tester.tap(find.text('+ Tambah').first);
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan Pesanan'));
      await tester.tap(find.text('Simpan Pesanan'));
      await tester.pump();

      expect(find.text('Isi nama pelanggan dulu'), findsOneWidget);
      expect(api.calls, isNot(contains('createBooking')));
    });

    testWidgets('histori: pilih pelanggan lama lalu pesan pakai id-nya', (
      tester,
    ) async {
      api.session = _openSession;
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Histori Pelanggan'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Iqbal Apriand'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);
      expect(find.text('Reguler'), findsOneWidget); // Budi

      await tester.tap(find.text('Pilih Pelanggan').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Member • 1.250 poin'), findsOneWidget);

      await tester.tap(find.text('+ Tambah').first);
      await tester.pump();
      await tester.ensureVisible(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih capster'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wahyu').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan Pesanan'));
      await tester.tap(find.text('Simpan Pesanan'));
      await tester.pumpAndSettle();

      expect(api.createdBookingCustomer, 'CUS-1');
      expect(api.customerList, hasLength(2)); // tidak buat pelanggan baru
    });

    testWidgets('no HP pelanggan lama muncul saran pakai data histori', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nomor Telepon'),
        '081300001111',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Pelanggan lama: Budi Santoso'), findsOneWidget);

      await tester.tap(find.text('Pakai'));
      await tester.pumpAndSettle();
      expect(find.text('Budi Santoso'), findsWidgets);
      expect(find.byTooltip('Ganti pelanggan'), findsWidgets);
    });

    testWidgets('reservasi booked: ubah status progress lalu bayar', (
      tester,
    ) async {
      api.session = _openSession;
      api.bookingList = [fakeBooking(price: 65000, discount: 15000)];
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);
      await tester.tap(find.text('Dari Reservasi'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih booking'), findsOneWidget);
      await tester.tap(find.text('Iqbal Apriand'));
      await tester.pumpAndSettle();
      expect(find.text('Member · Premium'), findsOneWidget);
      expect(find.text('1.250 poin'), findsOneWidget);
      expect(find.text('-Rp 15.000'), findsOneWidget);
      expect(find.text('Bayar'), findsNothing);

      await tester.tap(find.text('Ubah Status Progress'));
      await tester.pumpAndSettle();
      expect(api.calls, contains('checkIn:bkBK-1'));

      await tester.tap(find.text('QRIS'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Bayar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Konfirmasi & Cetak'));
      await tester.pumpAndSettle();

      expect(api.lastSale?.payment, PaymentType.cashless);
      expect(api.lastSale?.bookingId, 'BK-1');

      final text = printed();
      expect(text, contains(row('Pelanggan', 'Iqbal Apriand')));
      expect(text, contains(row('Diskon', '-Rp 15.000')));
      expect(text, contains(row('TOTAL', 'Rp 50.000')));
    });

    testWidgets('reservasi progress: ganti layanan, tetap 1 item', (
      tester,
    ) async {
      api.bookingList = [fakeBooking(status: BookingStatus.progress)];
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);
      await tester.tap(find.text('Dari Reservasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iqbal Apriand'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ganti Layanan / Paket'));
      await tester.pumpAndSettle();
      expect(find.text('Gentlement Grooming'), findsOneWidget);
      expect(find.text('Paket Ayah & Anak'), findsOneWidget);

      await tester.tap(find.text('Paket Ayah & Anak'));
      await tester.pumpAndSettle();
      expect(
        api.calls,
        containsAllInOrder(['addService:PKG-1', 'removeService:SVC-1']),
      );
      expect(api.bookingList.single.services.map((l) => l.item.id), ['PKG-1']);
      expect(find.textContaining('diganti Paket Ayah & Anak'), findsOneWidget);
    });

    testWidgets('booking selesai hanya bisa cetak struk', (tester) async {
      api.bookingList = [fakeBooking(status: BookingStatus.completed)];
      await pumpApp(tester);
      await signIn(tester);
      await openOrder(tester);
      await tester.tap(find.text('Dari Reservasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iqbal Apriand'));
      await tester.pumpAndSettle();

      expect(find.text('Bayar'), findsNothing);
      await tester.tap(find.text('Cetak Struk'));
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

      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Buka shift dulu untuk bayar'),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('pelanggan', () {
    Future<void> openCustomers(WidgetTester tester) async {
      await tester.tap(find.text('Pelanggan').first);
      await tester.pumpAndSettle();
    }

    testWidgets('daftar, filter member, detail, lalu proses di kasir', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openCustomers(tester);

      expect(find.text('Daftar Pelanggan'), findsOneWidget);
      expect(find.text('Iqbal Apriand'), findsWidgets);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Aplikasi'), findsOneWidget); // sumber data Iqbal
      expect(find.text('Kasir'), findsWidgets); // Budi + menu sidebar

      await tester.tap(find.text('Semua Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reguler').last);
      await tester.pumpAndSettle();
      expect(find.text('Iqbal Apriand'), findsNothing);
      expect(find.text('Budi Santoso'), findsWidgets);

      await tester.tap(find.text('Reguler').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Member').last);
      await tester.pumpAndSettle();
      expect(find.text('Budi Santoso'), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Pelanggan'), findsOneWidget);
      expect(find.text('iqbal@mail.com'), findsOneWidget);

      await tester.tap(find.text('Proses di Kasir'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Member • 1.250 poin'), findsOneWidget);
    });

    testWidgets('buat reservasi baru dari detail pelanggan', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await openCustomers(tester);

      await tester.tap(find.text('Budi Santoso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Reservasi Baru'));
      await tester.pumpAndSettle();
      expect(api.calls, contains('bookingSlots'));

      await tester.tap(find.text('10:30'));
      await tester.pump();
      await tester.tap(find.text('Rizal'));
      await tester.pump();
      await tester.tap(find.byType(DropdownButtonFormField<ServiceItem>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Gentlement Grooming').last);
      await tester.pumpAndSettle();
      await confirmAndSubmit(tester, 'Simpan');

      expect(api.createdBookingCustomer, 'CUS-2');
      expect(api.createdBookingCapster, 'CAP-2');
      expect(api.createdBookingServices, ['SVC-2']);
      final booking = api.bookingList.single;
      expect(booking.status, BookingStatus.booked);
      expect(booking.scheduledAt?.hour, 10);
      expect(booking.scheduledAt?.minute, 30);
    });
  });

  group('pembukuan', () {
    Future<void> openBookkeeping(WidgetTester tester) async {
      await tester.tap(find.text('Pembukuan').first);
      await tester.pumpAndSettle();
    }

    testWidgets('sesi kasir: pengeluaran, pemasukan booking, tutup shift', (
      tester,
    ) async {
      api.session = _openSession;
      api.bookingList = [fakeBooking(status: BookingStatus.progress)];
      await pumpApp(tester);
      await signIn(tester);
      await openBookkeeping(tester);

      expect(find.text('Saldo Awal'), findsWidgets);
      expect(find.text('Rp 100.000'), findsWidgets);

      // Pengeluaran
      await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '0').last, '20000');
      await tester.enterText(
        find.widgetWithText(TextField, 'Contoh: beli air mineral dan tisu'),
        'Beli sabun',
      );
      await tester.pump();
      await confirmAndSubmit(tester, 'Simpan');
      expect(api.lastOutcome?.amount, 20000);
      expect(find.text('Beli sabun'), findsOneWidget);

      // Pemasukan = bayar booking yang sedang dilayani
      await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pengeluaran').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pemasukan').last);
      await tester.pumpAndSettle();
      expect(api.calls, contains('bookings:progress'));
      await tester.tap(find.byType(DropdownButtonFormField<Booking>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Iqbal Apriand ·').last);
      await tester.pumpAndSettle();
      expect(find.text('45.000'), findsOneWidget); // ikut total booking
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      await confirmAndSubmit(tester, 'Simpan');

      expect(api.lastSale?.bookingId, 'BK-1');
      expect(api.lastSale?.amount, 45000);
      expect(api.lastSale?.payment, PaymentType.cashless);
      expect(api.bookingList.single.status, BookingStatus.completed);
      expect(find.text('Booking Iqbal Apriand'), findsOneWidget);
      expect(find.text('Non Tunai'), findsOneWidget);

      // Seharusnya: 100.000 + 0 tunai - 20.000 = 80.000
      expect(find.text('Rp 80.000'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '0'), '75000');
      await tester.pump();
      expect(find.text('Uang kurang'), findsOneWidget);
      expect(find.text('-Rp 5.000'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '75.000'), '80000');
      await tester.pump();
      expect(find.text('Saldo sesuai'), findsOneWidget);

      await tester.ensureVisible(find.text('TUTUP SHIFT'));
      await tester.tap(find.text('TUTUP SHIFT'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Tutup Shift'));
      await tester.pumpAndSettle();

      expect(api.closedWith, 80000);
      expect(find.text('Shift belum dibuka'), findsWidgets);
    });

    testWidgets('history harian: detail, cari kasir, dan cetak ringkasan', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openBookkeeping(tester);
      await tester.tap(find.text('History Harian'));
      await tester.pumpAndSettle();

      expect(find.text('Dewi Lestari'), findsWidgets); // tabel + detail
      expect(find.text('Rina Kasir'), findsOneWidget);
      // Shift pertama otomatis terpilih: 500k + 150k - 10k = 640k, pas
      expect(find.text('Sesuai (Selisih Rp 0)'), findsOneWidget);

      // Non-tunai tidak dihitung di laci: 500k + 45k = 545k, fisik 530k
      await tester.tap(find.widgetWithText(OutlinedButton, 'Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Kurang Rp 15.000'), findsOneWidget);
      expect(find.text('Dipilih'), findsOneWidget);

      await tester.tap(find.text('Cetak'));
      await tester.pumpAndSettle();
      final text = printed();
      expect(text, contains('Barberstuff Cikutra'));
      expect(text, contains(row('Kasir', 'Rina Kasir')));
      expect(text, contains(row('Seharusnya', 'Rp 545.000')));
      expect(text, contains(row('Selisih', '-Rp 15.000')));
      expect(text, contains('KURANG'));

      await tester.enterText(
        find.widgetWithText(TextField, 'Cari nama kasir...'),
        'rina',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(api.calls.last, endsWith(':rina'));
      expect(find.text('Dewi Lestari'), findsNothing);
    });

    testWidgets('admin: sesi kasir dikunci, history tetap bisa dilihat', (
      tester,
    ) async {
      api.staff = FakeApi.staffAs('admin');
      await pumpApp(tester);
      await signIn(tester);
      await openBookkeeping(tester);

      expect(find.text('Sesi kasir khusus akun kasir'), findsOneWidget);
      await tester.tap(find.text('History Harian'));
      await tester.pumpAndSettle();
      expect(find.text('Rina Kasir'), findsOneWidget);
    });
  });

  group('navigasi', () {
    testWidgets('sidebar bisa diperkecil jadi ikon dan dibesarkan lagi', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      expect(find.text('Konfigurasi'), findsOneWidget);

      await tester.tap(find.byTooltip('Perkecil menu'));
      await tester.pumpAndSettle();
      expect(find.text('Konfigurasi'), findsNothing);
      expect(_assetIcon(AppAsset.settingIcon), findsOneWidget);

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
  });
}
