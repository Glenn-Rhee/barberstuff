import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/login_response.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Pengganti backend di tes, sekaligus mencatat apa yang dikirim aplikasi
class FakeApi implements AuthApi, CatalogApi, BookingApi, CashSessionApi {
  static const password = 'rahasia';

  final calls = <String>[];

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

  String? createdBookingCapster;
  List<String> createdBookingServices = const [];
  ({int amount, PaymentType? payment, String? bookingId})? lastSale;
  int? openedWith;
  int? closedWith;

  // Isi untuk tiru backend yang menolak tutup kas di jam operasional
  String? closeError;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    calls.add('login');
    if (password != FakeApi.password) {
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
    return Paged(
      items: bookingList,
      totalPages: 1,
      totalData: bookingList.length,
    );
  }

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
    return 'bk-0123456789';
  }

  @override
  Future<void> checkIn(String qrCode) async {
    calls.add('checkIn:$qrCode');
  }

  @override
  Future<void> addService({
    required String bookingId,
    required String serviceId,
  }) async {
    calls.add('addService');
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
        ),
      ],
    );
  }
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
