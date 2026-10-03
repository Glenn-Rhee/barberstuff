/// Slot satu capster pada satu waktu, untuk mengunci atau melepasnya.
class BookingSlotParams {
  const BookingSlotParams({
    required this.storeId,
    required this.capsterId,
    required this.bookingDate,
  });

  final String storeId;
  final String capsterId;
  final DateTime bookingDate;
}
