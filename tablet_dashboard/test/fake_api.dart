import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/login_response.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/customer/data/customer_api.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_kpi.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking_customer.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking_slot.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/store/data/store_api.dart';
import 'package:tablet_dashboard/features/cashier/store/domain/entities/store_info.dart';

// Pengganti backend di tes, sekaligus mencatat apa yang dikirim aplikasi
class FakeApi
    implements
        AuthApi,
        CatalogApi,
        BookingApi,
        CashSessionApi,
        StoreApi,
        CustomerApi {
  static const defaultPassword = 'rahasia';

  // Berubah kalau reset password berhasil
  String password = defaultPassword;

  final calls = <String>[];

  // Isi untuk tiru server lambat di GET /booking (lihat kerangka loading)
  Duration? bookingsDelay;

  StaffProfile staff = staffAs('cashier');

  static StaffProfile staffAs(String role) => StaffProfile(
    id: 'STF-1',
    name: 'Wibawa Mukti',
    email: 'staff@barberstuff.id',
    role: role,
    storeId: 'STORE-1',
  );

  List<ServiceItem> catalog = const [
    ServiceItem(id: 'SVC-1', name: 'Classic Hair Cut', price: 45000),
    ServiceItem(id: 'SVC-2', name: 'Gentlement Grooming', price: 65000),
  ];
  List<ServiceItem> packages = const [
    ServiceItem(
      id: 'PKG-1',
      name: 'Paket Ayah & Anak',
      price: 85000,
      type: ServiceType.package,
    ),
  ];
  List<Capster> capsterList = const [
    Capster(id: 'CAP-1', name: 'Wahyu', rating: 5),
    Capster(id: 'CAP-2', name: 'Rizal', rating: 4.5),
  ];
  List<Booking> bookingList = [];
  CashSession? session;

  // Histori pelanggan: Iqbal pakai aplikasi (member), Budi reguler
  List<CustomerProfile> customerList = [
    CustomerProfile(
      id: 'CUS-1',
      name: 'Iqbal Apriand',
      phone: '081234567890',
      email: 'iqbal@mail.com',
      points: 1250,
      totalVisited: 4,
      lastVisitedAt: DateTime(2026, 9, 20, 10),
      favoriteService: 'Classic Hair Cut',
      favoriteCapster: 'Wahyu',
    ),
    const CustomerProfile(
      id: 'CUS-2',
      name: 'Budi Santoso',
      phone: '081300001111',
      totalVisited: 1,
    ),
  ];

  String? createdBookingCustomer;

  // Isi untuk tiru backend yang menolak membuat booking
  String? createError;

  // Tiru booking dari aplikasi pelanggan: QR = "bk" + 4 karakter pertama id
  bool shortQr = false;

  String? createdBookingCapster;
  List<String> createdBookingServices = const [];
  ({int amount, PaymentType? payment, String? bookingId})? lastSale;
  int? openedWith;
  int? closedWith;

  // Isi untuk tiru backend yang menolak tutup kas di jam operasional
  String? closeError;

  ({int amount, String? title})? lastOutcome;

  // Shift yang sudah ditutup (History Harian)
  List<CashHistoryEntry> historyList = [
    CashHistoryEntry(
      id: 'CS-OLD-1',
      openingBalance: 500000,
      actualCash: 640000,
      incomeCash: 150000,
      incomeCashless: 90000,
      outcome: 10000,
      openedAt: _thisMonth(2, 9),
      closedAt: _thisMonth(2, 21),
      storeName: 'Barberstuff Cikutra',
      staffName: 'Dewi Lestari',
    ),
    CashHistoryEntry(
      id: 'CS-OLD-2',
      openingBalance: 500000,
      actualCash: 530000,
      incomeCash: 45000,
      incomeCashless: 0,
      outcome: 0,
      openedAt: _thisMonth(1, 9),
      closedAt: _thisMonth(1, 21),
      storeName: 'Barberstuff Cikutra',
      staffName: 'Rina Kasir',
    ),
  ];

  StoreInfo storeInfo = const StoreInfo(
    id: 'STORE-1',
    name: 'Barberstuff Cikutra',
    openHour: '09:00',
    closeHour: '21:00',
  );
  List<StoreInfo> branches = const [
    StoreInfo(id: 'STORE-1', name: 'Barberstuff Cikutra'),
    StoreInfo(id: 'STORE-2', name: 'Barberstuff Depok'),
  ];

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    calls.add('login');
    if (password != this.password) {
      throw const ApiException('Password salah', statusCode: 401);
    }
    return LoginResponse(token: 'token-123', email: email, role: staff.role);
  }

  @override
  Future<StaffProfile> profile() async {
    calls.add('profile');
    return staff;
  }

  @override
  Future<void> updateAccount({
    required String staffId,
    required String name,
    required String password,
  }) async {
    calls.add('updateAccount:$staffId');
    this.password = password;
  }

  @override
  Future<List<StoreInfo>> stores() async {
    calls.add('stores');
    return branches;
  }

  @override
  Future<StoreInfo> store(String id) async {
    calls.add('store:$id');
    return branches.firstWhere((s) => s.id == id, orElse: () => storeInfo);
  }

  @override
  Future<StoreInfo?> storeFromCashHistory() async {
    calls.add('cashHistory');
    return storeInfo;
  }

  @override
  Future<({String open, String close})?> hoursFromSlots(
    String storeId,
    DateTime date,
  ) async {
    calls.add('slots');
    return (open: '09:00', close: '21:00');
  }

  @override
  Future<Paged<ServiceItem>> services({
    required String storeId,
    required ServiceType type,
    String? name,
    int page = 1,
    int limit = 12,
  }) async {
    calls.add('services:${type.api}:${name ?? ''}');
    final all = type == ServiceType.package ? packages : catalog;
    final items = name == null
        ? all
        : [
            for (final item in all)
              if (item.name.toLowerCase().contains(name.toLowerCase())) item,
          ];
    return Paged(items: items, totalPages: 1, totalData: items.length);
  }

  @override
  Future<List<Capster>> capsters(String storeId) async {
    calls.add('capsters');
    return capsterList;
  }

  @override
  Future<Paged<Booking>> bookings({
    BookingStatus? status,
    String? query,
    int page = 1,
    int limit = 5,
  }) async {
    calls.add('bookings:${status?.api ?? 'all'}');
    if (bookingsDelay != null) await Future<void>.delayed(bookingsDelay!);
    final items = [
      for (final booking in bookingList)
        if (status == null || booking.status == status) booking,
    ];
    return Paged(items: items, totalPages: 1, totalData: items.length);
  }

  // Tiru backend: pelanggan dari id, atau dicari / dibuat dari no HP
  @override
  Future<String> createBooking({
    required String storeId,
    required String capsterId,
    required List<String> serviceIds,
    required DateTime bookingDate,
    String? customerId,
    String? customerName,
    String? customerPhone,
    bool scheduled = false,
  }) async {
    calls.add('createBooking');
    createdBookingCapster = capsterId;
    createdBookingServices = serviceIds;
    createdBookingCustomer = customerId;
    if (createError != null) throw ApiException(createError!, statusCode: 406);

    var customer = customerId != null
        ? customerList.firstWhere((c) => c.id == customerId)
        : customerList.where((c) => c.phone == customerPhone).firstOrNull;
    if (customer == null) {
      customer = CustomerProfile(
        id: 'CUS-NEW-${customerList.length + 1}',
        name: customerName!,
        phone: customerPhone,
      );
      customerList = [customer, ...customerList];
    }
    final items = [
      for (final item in [...catalog, ...packages])
        if (serviceIds.contains(item.id)) item,
    ];
    final total = items.fold(0, (sum, item) => sum + item.price);
    bookingList = [
      ...bookingList,
      Booking(
        id: 'BK-NEW-${bookingList.length + 1}',
        customer: BookingCustomer(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
        ),
        capster: capsterList.firstWhere((c) => c.id == capsterId),
        scheduledAt: bookingDate,
        services: [for (final item in items) CartLine(item)],
        subtotal: total,
        discount: 0,
        total: total,
        status: scheduled ? BookingStatus.booked : BookingStatus.progress,
      ),
    ];
    return '';
  }

  @override
  Future<void> checkIn(String qrCode) async {
    calls.add('checkIn:$qrCode');
    String qrOf(Booking b) =>
        shortQr ? 'bk${b.id.substring(0, 4)}' : 'bk${b.id}';
    final booking = bookingList.where((b) => qrOf(b) == qrCode).firstOrNull;
    if (booking == null) {
      throw const ApiException('Booking tidak ditemukan.', statusCode: 406);
    }
    if (booking.status != BookingStatus.booked) {
      throw const ApiException(
        'Booking tidak ditemukan atau telah checkin sebelumnya.',
        statusCode: 406,
      );
    }
    _replace(booking, status: BookingStatus.progress);
  }

  @override
  Future<void> addService({
    required String bookingId,
    required String serviceId,
  }) async {
    calls.add('addService:$serviceId');
    final booking = bookingList.firstWhere((b) => b.id == bookingId);
    final item = [...catalog, ...packages].firstWhere((s) => s.id == serviceId);
    _replace(booking, services: [...booking.services, CartLine(item)]);
  }

  // Tiru backend: hapus layanan, booking tidak boleh kosong
  @override
  Future<void> removeService({
    required String bookingId,
    required String serviceId,
  }) async {
    calls.add('removeService:$serviceId');
    final booking = bookingList.firstWhere((b) => b.id == bookingId);
    final lines = [
      for (final line in booking.services)
        if (line.item.id != serviceId) line,
    ];
    if (lines.isEmpty) {
      throw const ApiException(
        'Booking minimal punya 1 layanan.',
        statusCode: 406,
      );
    }
    _replace(booking, services: lines);
  }

  // Tiga slot, semua capster kosong
  @override
  Future<List<BookingSlot>> slots({
    required String storeId,
    required DateTime date,
  }) async {
    calls.add('bookingSlots');
    return [
      for (final time in const ['10:00', '10:30', '11:00'])
        BookingSlot(
          time: time,
          available: true,
          capsters: [
            for (final c in capsterList)
              SlotCapster(id: c.id, name: c.name, available: true),
          ],
        ),
    ];
  }

  @override
  Future<CustomerPage> customers({
    String? query,
    int page = 1,
    int limit = 12,
  }) async {
    calls.add('customers:${query ?? ''}');
    final q = query?.toLowerCase();
    final matched = [
      for (final customer in customerList)
        if (q == null ||
            customer.phone == query ||
            customer.name.toLowerCase().contains(q))
          customer,
    ];
    final items = matched.skip((page - 1) * limit).take(limit).toList();
    final paged = Paged.fromPage(items, page: page, limit: limit);
    return CustomerPage(
      items: paged.items,
      totalPages: paged.totalPages,
      totalData: paged.totalData,
      kpi: CustomerKpi(total: customerList.length, newThisMonth: 1),
    );
  }

  // Booking tidak bisa diubah, jadi diganti salinan baru
  void _replace(
    Booking booking, {
    BookingStatus? status,
    List<CartLine>? services,
  }) {
    final lines = services ?? booking.services;
    final total = lines.fold(0, (sum, line) => sum + line.subtotal);
    final copy = Booking(
      id: booking.id,
      customer: booking.customer,
      capster: booking.capster,
      scheduledAt: booking.scheduledAt,
      services: lines,
      subtotal: total,
      discount: booking.discount,
      total: total - booking.discount,
      status: status ?? booking.status,
    );
    bookingList = [for (final b in bookingList) b.id == booking.id ? copy : b];
  }

  @override
  Future<Paged<CashHistoryEntry>> history({
    required DateTime month,
    String? query,
    String? storeId,
    int page = 1,
    int limit = 10,
  }) async {
    calls.add('history:${month.year}-${month.month}:${query ?? ''}');
    final q = query?.toLowerCase();
    final items = [
      for (final e in historyList)
        if (e.openedAt.year == month.year &&
            e.openedAt.month == month.month &&
            (q == null || (e.staffName ?? '').toLowerCase().contains(q)))
          e,
    ].skip((page - 1) * limit).take(limit).toList();
    return Paged.fromPage(items, page: page, limit: limit);
  }

  @override
  Future<CashSession?> cashSession() async {
    calls.add('cashSession');
    return session;
  }

  @override
  Future<String> openCashSession(int openingBalance) async {
    calls.add('openCashSession');
    openedWith = openingBalance;
    session = CashSession(
      id: 'CS-1',
      openingBalance: openingBalance,
      incomeCash: 0,
      incomeCashless: 0,
      outcome: 0,
      transactions: const [],
    );
    return session!.id;
  }

  @override
  Future<({int difference, String status})> closeCashSession({
    required String sessionId,
    required int amountActual,
  }) async {
    calls.add('closeCashSession');
    if (closeError != null) throw ApiException(closeError!, statusCode: 400);
    closedWith = amountActual;
    final expected = session?.expectedCash ?? 0;
    session = null;
    return (
      difference: amountActual - expected,
      status: amountActual == expected ? 'balance' : 'over',
    );
  }

  @override
  Future<void> createTransaction({
    required String sessionId,
    required TransactionType type,
    required int amount,
    PaymentType? paymentType,
    String? title,
    String? description,
    String? bookingId,
  }) async {
    calls.add('transaction:${type.name}');
    if (type == TransactionType.income) {
      lastSale = (amount: amount, payment: paymentType, bookingId: bookingId);
      final booking = bookingList.where((b) => b.id == bookingId).firstOrNull;
      if (booking != null) _replace(booking, status: BookingStatus.completed);
    } else {
      lastOutcome = (amount: amount, title: title);
    }
    final current = session!;
    session = CashSession(
      id: current.id,
      openingBalance: current.openingBalance,
      incomeCash:
          current.incomeCash +
          (type == TransactionType.income && paymentType == PaymentType.cash
              ? amount
              : 0),
      incomeCashless:
          current.incomeCashless +
          (type == TransactionType.income && paymentType == PaymentType.cashless
              ? amount
              : 0),
      outcome: current.outcome + (type == TransactionType.outcome ? amount : 0),
      transactions: [
        ...current.transactions,
        CashTransaction(
          id: 'TRX-${current.transactions.length + 1}',
          title: title ?? '-',
          amount: amount,
          type: type,
          paymentType: paymentType,
          description: description,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }
}

// Tanggal di bulan berjalan, supaya History Harian bulan ini selalu terisi
DateTime _thisMonth(int day, int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, day, hour);
}

// Booking dengan bentuk yang sama seperti respons GET /booking
Booking fakeBooking({
  String id = 'BK-1',
  String customer = 'Iqbal Apriand',
  String capster = 'Wahyu',
  BookingStatus status = BookingStatus.booked,
  int price = 45000,
  int discount = 0,
}) {
  return Booking.fromJson({
    'customer': {
      'id': 'CUS-1',
      'name': customer,
      'phone_number': '0812-3456-7890',
      'premium_type': 'Premium',
      'member_points': 1250,
      'service_favorite': 'Classic Hair Cut',
    },
    'booking': {
      'id': id,
      'scheduled_at': '2026-09-24T07:30:00Z',
      'capster': {'id': 'CAP-1', 'name': capster, 'avg_rating': 5},
      'sub_total': '$price',
      'discount_amount': '$discount',
      'total_price': '${price - discount}',
      'status_booking': status.api,
      'services': [
        {'id': 'SVC-1', 'name': 'Classic Hair Cut', 'price': '$price'},
      ],
    },
  });
}
