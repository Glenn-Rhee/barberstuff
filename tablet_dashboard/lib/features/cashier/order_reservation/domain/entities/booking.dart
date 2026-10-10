import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/json_value.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking_customer.dart';

enum BookingStatus {
  booked('booked', 'Booked'),
  progress('progress', 'Progress'),
  completed('completed', 'Completed'),
  canceled('canceled', 'Cancel');

  const BookingStatus(this.api, this.label);

  final String api;
  final String label;

  static BookingStatus parse(String? value) =>
      values.where((s) => s.api == value).firstOrNull ?? BookingStatus.booked;

  bool get isFinal => this == completed || this == canceled;
}

// Satu baris GET /booking: data pelanggan + booking
class Booking {
  const Booking({
    required this.id,
    required this.customer,
    required this.capster,
    required this.scheduledAt,
    required this.services,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final booking = (json['booking'] as Map? ?? const {})
        .cast<String, dynamic>();
    final capster = (booking['capster'] as Map? ?? const {})
        .cast<String, dynamic>();
    // Backend kirim 1 baris per item, layanan yang sama digabung jadi jumlah
    final qty = <ServiceItem, int>{};
    for (final item in (booking['services'] as List? ?? const [])) {
      if (item is! Map) continue;
      final service = ServiceItem(
        id: item['id'] as String? ?? '',
        name: item['name'] as String? ?? '-',
        price: parseAmount(item['price']),
      );
      qty.update(service, (count) => count + 1, ifAbsent: () => 1);
    }
    final services = [
      for (final MapEntry(:key, :value) in qty.entries) CartLine(key, value),
    ];
    return Booking(
      id: booking['id'] as String? ?? '',
      customer: BookingCustomer.fromJson(
        (json['customer'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
      capster: Capster.fromJson(capster),
      scheduledAt: DateTime.tryParse(booking['scheduled_at'] as String? ?? '')
          ?.toLocal(),
      services: services,
      subtotal: parseAmount(booking['sub_total']),
      discount: parseAmount(booking['discount_amount']),
      total: parseAmount(booking['total_price']),
      status: BookingStatus.parse(booking['status_booking'] as String?),
    );
  }

  final String id;
  final BookingCustomer customer;
  final Capster capster;
  final DateTime? scheduledAt;
  final List<CartLine> services;
  final int subtotal;
  final int discount;
  final int total;
  final BookingStatus status;

  // Jadwal booking jatuh di hari [day] (jam lokal tablet)
  bool isOn(DateTime day) {
    final at = scheduledAt;
    return at != null && DateFormatId.isSameDay(at, day);
  }

  // Jumlah [serviceId] di booking ini, 0 = tidak ada
  int qtyOf(String serviceId) =>
      services.where((line) => line.item.id == serviceId).firstOrNull?.qty ?? 0;

  // Total item di server (layanan x jumlah), backend tolak hapus yang terakhir
  int get itemCount => services.fold(0, (sum, line) => sum + line.qty);

  // Total potongan = subtotal - total (backend menimpa discount_amount)
  int get totalDiscount => subtotal > total ? subtotal - total : 0;
}
