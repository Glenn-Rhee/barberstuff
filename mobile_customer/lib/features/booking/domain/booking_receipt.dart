import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';

class BookingReceipt {
  const BookingReceipt({
    required this.orderId,
    required this.store,
    required this.capster,
    required this.date,
    required this.time,
    required this.services,
    required this.customerName,
    required this.customerPhone,
  });

  final String orderId;
  final BookingStore store;
  final BookingCapster capster;
  final DateTime date;
  final TimeOfDay time;
  final List<BookingService> services;
  final String customerName;
  final String customerPhone;

  int get total =>
      services.fold(0, (int sum, BookingService s) => sum + s.price);
}
