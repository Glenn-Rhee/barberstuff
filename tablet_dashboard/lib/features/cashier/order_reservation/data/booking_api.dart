import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
<<<<<<< HEAD:tablet_dashboard/lib/features/cashier/reservation/data/booking_api.dart
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking_slot.dart';
=======
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking_slot.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/cashier/order_reservation/data/booking_api.dart

// Booking toko: list, buat di kasir, check-in, tambah layanan
class BookingApi {
  const BookingApi(this._client);

  final ApiClient _client;

<<<<<<< HEAD:tablet_dashboard/lib/features/cashier/reservation/data/booking_api.dart
  // [date] = hari booking yang diminta, null = hari ini.
  // Backend sekarang masih selalu kirim booking hari ini dan mengabaikan
  // `date`, jadi booking di luar [date] dibuang supaya tidak tampil di
  // tanggal yang salah
=======
  // [date] null = hari ini. Backend belum pakai `date`, jadi disaring di sini
>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/cashier/order_reservation/data/booking_api.dart
  Future<Paged<Booking>> bookings({
    BookingStatus? status,
    String? query,
    DateTime? date,
    int page = 1,
    int limit = 5,
  }) async {
    final day = date == null ? null : DateTime(date.year, date.month, date.day);
    final res = await _client.get(
      '/booking/',
      query: {
        'status_booking': status?.api,
        'q': query,
        // Format sama dengan /booking/store: awal hari lokal dalam UTC
        'date': day?.toUtc().toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );
    final items = [for (final json in res.list) Booking.fromJson(json)];
    return Paged.fromPage(
      [
        for (final booking in items)
          if (day == null || booking.isOn(day)) booking,
      ],
      page: page,
      limit: limit,
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

  // Jam booking yang tersedia di satu tanggal + capster kosong per jam
  Future<List<BookingSlot>> slots({
    required String storeId,
    required DateTime date,
  }) async {
    final res = await _client.get(
      '/booking/store',
      query: {'id_store': storeId, 'date': date.toUtc().toIso8601String()},
    );
    return [
      for (final slot in (res.map['slots'] as List? ?? const []))
        if (slot is Map) BookingSlot.fromJson(slot.cast()),
    ];
  }

  Future<void> checkIn(String qrCode) =>
      _client.patch('/staff/booking/checkin/$qrCode');

<<<<<<< HEAD:tablet_dashboard/lib/features/cashier/reservation/data/booking_api.dart
  // Hapus satu layanan dari booking (DELETE /staff/booking/item),
  // backend menolak kalau booking jadi kosong
=======
  // Hapus satu layanan, backend menolak booking kosong
>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/cashier/order_reservation/data/booking_api.dart
  Future<void> removeService({
    required String bookingId,
    required String serviceId,
  }) => _client.delete(
    '/staff/booking/item',
    data: {'id_booking': bookingId, 'id_service': serviceId},
  );

  // Tambah satu layanan ke booking (POST /staff/booking/item)
  Future<void> addService({
    required String bookingId,
    required String serviceId,
  }) => _client.post(
    '/staff/booking/item',
    data: {'id_booking': bookingId, 'id_service': serviceId},
  );

  Future<void> cancel({
    required String bookingId,
    required String notes,
  }) async {
    _client.patch('/staff/booking/$bookingId', data: {'notes': notes});
  }
}
