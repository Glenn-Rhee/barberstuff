import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';

// Booking toko: list, buat di kasir, check-in, tambah layanan
class BookingApi {
  const BookingApi(this._client);

  final ApiClient _client;

  Future<Paged<Booking>> bookings({
    BookingStatus? status,
    String? query,
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _client.get(
      '/booking/',
      query: {
        'status_booking': status?.api,
        'q': query,
        'page': page,
        'limit': limit,
      },
    );
    return Paged(
      items: [for (final json in res.list) Booking.fromJson(json)],
      totalPages: res.totalPages,
      totalData: res.totalData,
    );
  }

  // Pesanan langsung / booking dari kasir (POST /staff/booking)
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
    final res = await _client.post(
      '/staff/booking/',
      data: {
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
    return res.map['id_booking'] as String? ?? res.map['id'] as String? ?? '';
  }

  Future<void> checkIn(String qrCode) =>
      _client.patch('/staff/booking/checkin/$qrCode');

  // Tambah satu layanan ke booking (POST /staff/booking/item)
  Future<void> addService({
    required String bookingId,
    required String serviceId,
  }) => _client.post(
    '/staff/booking/item',
    data: {'id_booking': bookingId, 'id_service': serviceId},
  );
}
