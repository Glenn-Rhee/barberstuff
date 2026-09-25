import '../../../shared/models/person.dart';
import '../../../shared/models/service_item.dart';

enum BookingStatus {
  booked('booked', 'Booked'),
  progress('progress', 'Progress'),
  completed('completed', 'Completed'),
  canceled('canceled', 'Cancel');

  const BookingStatus(this.api, this.label);

  final String api;
  final String label;

  static BookingStatus parse(String? value) => values.where((s) => s.api == value).firstOrNull ?? BookingStatus.booked;

  bool get isFinal => this == completed || this == canceled;
}

/// One row of `GET /booking` as the cashier sees it: customer + booking.
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
    final booking = (json['booking'] as Map? ?? const {}).cast<String, dynamic>();
    final capster = (booking['capster'] as Map? ?? const {}).cast<String, dynamic>();
    final services = [
      for (final item in (booking['services'] as List? ?? const []))
        if (item is Map)
          CartLine(
            ServiceItem(
              id: item['id'] as String? ?? '',
              name: item['name'] as String? ?? '-',
              price: ServiceItem.parsePrice(item['price']),
            ),
          ),
    ];
    return Booking(
      id: booking['id'] as String? ?? '',
      customer: BookingCustomer.fromJson((json['customer'] as Map? ?? const {}).cast<String, dynamic>()),
      capster: Capster.fromJson(capster),
      scheduledAt: DateTime.tryParse(booking['scheduled_at'] as String? ?? '')?.toLocal(),
      services: services,
      subtotal: ServiceItem.parsePrice(booking['sub_total']),
      discount: ServiceItem.parsePrice(booking['discount_amount']),
      total: ServiceItem.parsePrice(booking['total_price']),
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
}
