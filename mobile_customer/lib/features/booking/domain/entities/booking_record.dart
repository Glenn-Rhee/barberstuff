enum BookingStatus { booked, progress, completed, canceled }

class BookingLine {
  const BookingLine({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;
}

/// Ulasan yang sudah dikirim, disimpan utuh supaya bisa dilihat lagi.
class BookingReview {
  const BookingReview({
    required this.capster,
    required this.cashier,
    required this.store,
    required this.message,
  });

  final int capster;
  final int cashier;
  final int store;
  final String message;

  double get average => (capster + cashier + store) / 3;
}

/// Satu booking untuk struk, beranda, dan riwayat. Sumbernya bisa hasil
/// membuat booking dari perangkat ini (tersimpan di jurnal perangkat) atau
/// daftar booking akun dari server.
class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.qrCode,
    required this.scheduledAt,
    required this.createdAt,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.capsterId,
    required this.capsterName,
    required this.lines,
    required this.appServiceFee,
    required this.totalPrice,
    this.staffId = '',
    this.status,
    this.canceled = false,
    this.review,
  });

  final String id;
  final String qrCode;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String capsterId;
  final String capsterName;
  final List<BookingLine> lines;

  /// 0 berarti tidak diketahui: daftar dari server tidak mengirim biaya ini.
  final int appServiceFee;

  /// `total_price` dari backend, sudah termasuk [appServiceFee] dan potongan
  /// promo. Tampilkan apa adanya, jangan ditambah atau dikurangi lagi.
  final double totalPrice;

  /// Kasir yang menangani, dibutuhkan untuk rating. Kosong untuk booking lokal.
  final String staffId;

  /// Status dari server. null untuk booking yang baru dibuat di perangkat.
  final BookingStatus? status;

  final bool canceled;
  final BookingReview? review;

  double? get reviewScore => review?.average;

  String get serviceName => lines.map((BookingLine l) => l.name).join(' - ');

  bool get isReviewed => reviewScore != null;

  BookingStatus statusAt(DateTime now) {
    final BookingStatus? known = status;
    if (known != null) return known;
    if (canceled) return BookingStatus.canceled;
    return scheduledAt.isAfter(now)
        ? BookingStatus.booked
        : BookingStatus.completed;
  }

  BookingRecord copyWith({bool? canceled, BookingReview? review}) {
    return BookingRecord(
      id: id,
      qrCode: qrCode,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      storeId: storeId,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      capsterId: capsterId,
      capsterName: capsterName,
      lines: lines,
      appServiceFee: appServiceFee,
      totalPrice: totalPrice,
      staffId: staffId,
      status: status,
      canceled: canceled ?? this.canceled,
      review: review ?? this.review,
    );
  }
}
