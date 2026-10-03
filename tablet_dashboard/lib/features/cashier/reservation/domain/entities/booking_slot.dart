// Satu jam booking di toko (GET /booking/store), tiap 30 menit
class BookingSlot {
  const BookingSlot({
    required this.time,
    required this.available,
    required this.capsters,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) => BookingSlot(
    time: json['time'] as String? ?? '',
    available: json['available'] as bool? ?? false,
    capsters: [
      for (final c in (json['capsters'] as List? ?? const []))
        if (c is Map)
          SlotCapster(
            id: c['id'] as String? ?? '',
            name: c['name'] as String? ?? '-',
            available: c['available'] as bool? ?? false,
          ),
    ],
  );

  // Format "14:30", jam lokal toko
  final String time;
  final bool available;
  final List<SlotCapster> capsters;

  List<SlotCapster> get freeCapsters => [
    for (final c in capsters)
      if (c.available) c,
  ];
}

// Capster di satu slot dan apakah masih kosong
class SlotCapster {
  const SlotCapster({
    required this.id,
    required this.name,
    required this.available,
  });

  final String id;
  final String name;
  final bool available;
}
