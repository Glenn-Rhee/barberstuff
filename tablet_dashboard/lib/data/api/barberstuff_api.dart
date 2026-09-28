import '../../core/network/api_client.dart';
import '../../features/dashboard/domain/cash_session.dart';
import '../../features/reservation/domain/booking.dart';
import '../../shared/models/person.dart';
import '../../shared/models/service_item.dart';

class Paged<T> {
  const Paged({
    required this.items,
    required this.totalPages,
    required this.totalData,
  });

  final List<T> items;
  final int totalPages;
  final int totalData;
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.role,
    required this.email,
  });

  final String token;
  final String role;
  final String email;
}

/// Every call the kasir tablet makes. Paths match the backend routes 1:1.
class BarberstuffApi {
  BarberstuffApi(this.client);

  final ApiClient client;

  // ---- auth -------------------------------------------------------------
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final result = await client.post(
      '/auth/login/credential',
      body: {'email': email, 'password': password},
    );
    final user = (result.map['user'] as Map? ?? const {})
        .cast<String, dynamic>();
    return LoginResult(
      token: result.map['access_token'] as String? ?? '',
      role: user['role'] as String? ?? '',
      email: user['email'] as String? ?? email,
    );
  }

  Future<StaffProfile> profile() async =>
      StaffProfile.fromJson((await client.get('/profile/staff')).map);

  // ---- catalog ----------------------------------------------------------
  Future<Paged<ServiceItem>> services({
    required String storeId,
    required ServiceType type,
    String? name,
    int page = 1,
    int limit = 12,
  }) async {
    final result = await client.get(
      '/service/',
      query: {
        'id_store': storeId,
        'type': type.api,
        'name': name,
        'page': page,
        'limit': limit,
      },
    );
    return Paged(
      items: [for (final json in result.list) ServiceItem.fromJson(json)],
      totalPages: result.totalPages,
      totalData: result.totalData,
    );
  }

  Future<List<Capster>> capsters(String storeId) async {
    final result = await client.get(
      '/capster/',
      query: {'id_store': storeId, 'limit': 50},
    );
    return [for (final json in result.list) Capster.fromJson(json)];
  }

  // ---- bookings ---------------------------------------------------------
  Future<Paged<Booking>> bookings({
    BookingStatus? status,
    String? query,
    int page = 1,
    int limit = 5,
  }) async {
    final result = await client.get(
      '/booking/',
      query: {
        'status_booking': status?.api,
        'q': query,
        'page': page,
        'limit': limit,
      },
    );
    return Paged(
      items: [for (final json in result.list) Booking.fromJson(json)],
      totalPages: result.totalPages,
      totalData: result.totalData,
    );
  }

  /// Walk-in order or a booking made at the counter (`POST /staff/booking`).
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
    final result = await client.post(
      '/staff/booking/',
      body: {
        'id_store': storeId,
        'id_capster': capsterId,
        'id_services': serviceIds,
        'booking_date': bookingDate.toUtc().toIso8601String(),
        'customer': {
          'id': ?customerId,
          if (customerName != null && customerName.isNotEmpty)
            'name': customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            'phoneNumber': customerPhone,
        },
        'is_booking': scheduled ? 'booking' : 'order',
      },
    );
    return result.map['id_booking'] as String? ??
        result.map['id'] as String? ??
        '';
  }

  Future<void> checkIn(String qrCode) =>
      client.patch('/staff/booking/checkin/$qrCode');

  // ---- cash session (shift) --------------------------------------------
  /// Today's open session, or `null` when no shift is open yet.
  Future<CashSession?> cashSession() async {
    try {
      return CashSession.fromJson((await client.get('/cash-sessions/')).map);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 404)
        return null; // "Transaksi pembukuan telah ditutup."
      rethrow;
    }
  }

  Future<String> openCashSession(int saldoBegin) async {
    final result = await client.post(
      '/cash-sessions/',
      body: {'saldo_begin': saldoBegin},
    );
    return result.map['id'] as String? ?? '';
  }

  /// Returns the difference between counted and expected cash.
  Future<({int difference, String status})> closeCashSession({
    required String sessionId,
    required int amountActual,
  }) async {
    final result = await client.patch(
      '/cash-sessions/',
      body: {'id_cash_session': sessionId, 'amount_actual': amountActual},
    );
    return (
      difference: ServiceItem.parsePrice(result.map['amount_difference']),
      status: result.map['status'] as String? ?? '',
    );
  }

  // ---- transactions -----------------------------------------------------
  Future<void> createTransaction({
    required String sessionId,
    required TransactionType type,
    required int amount,
    PaymentType? paymentType,
    String? title,
    String? description,
    String? bookingId,
  }) {
    return client.post(
      '/transactions/',
      body: {
        'id_cash_session': sessionId,
        'transaction_type': type.name,
        'amount': amount,
        'payment_type': ?paymentType?.api,
        'title': ?title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'id_booking': ?bookingId,
      },
    );
  }
}
