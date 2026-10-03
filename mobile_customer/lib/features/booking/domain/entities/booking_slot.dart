class SlotCapster {
  const SlotCapster({
    required this.id,
    required this.name,
    required this.avgRating,
    required this.imageUrl,
    required this.available,
  });

  final String id;
  final String name;
  final double avgRating;
  final String imageUrl;
  final bool available;
}

class BookingSlot {
  const BookingSlot({
    required this.time,
    required this.available,
    required this.capsters,
  });

  /// Jam dinding cabang, misalnya "20:00".
  final String time;
  final bool available;
  final List<SlotCapster> capsters;

  List<SlotCapster> get availableCapsters =>
      capsters.where((SlotCapster c) => c.available).toList(growable: false);
}

/// Jadwal satu cabang pada satu hari.
class StoreSlots {
  const StoreSlots({
    required this.idStore,
    required this.date,
    required this.slots,
  });

  final String idStore;
  final DateTime date;
  final List<BookingSlot> slots;
}
