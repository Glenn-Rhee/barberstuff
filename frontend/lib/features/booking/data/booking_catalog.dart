import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';

class BookingCatalog extends ChangeNotifier {
  static const List<String> _capsterPhotos = <String>[
    AppAssets.capster1,
    AppAssets.capster2,
    AppAssets.capster3,
    AppAssets.capster4,
  ];

  static const List<BookingStore> _seedStores = <BookingStore>[
    BookingStore(
      id: 's1',
      name: 'Kemang Raya',
      address: 'Jl. Metro Pondok Indah No. 12, Jakarta Selatan',
      distanceKm: 0.6,
      isLite: true,
    ),
    BookingStore(
      id: 's2',
      name: 'Pondok Indah',
      address: 'Jl. Metro Pondok Indah No. 45, Jakarta Selatan',
      distanceKm: 3.2,
    ),
    BookingStore(
      id: 's3',
      name: 'Kebun Raya Bogor',
      address: 'Jl. Ir. H. Juanda No. 13, Bogor Tengah',
      distanceKm: 0.6,
      isLite: true,
    ),
    BookingStore(
      id: 's4',
      name: 'Pondok Gede',
      address: 'Gg. Leopard Jl. Jatimakmur No. 49C, Kota Bekasi',
      distanceKm: 3.2,
    ),
  ];

  static const List<BookingCapster> _seedCapsters = <BookingCapster>[
    BookingCapster(
      id: 'c1',
      name: 'Dimas A.',
      photoAsset: AppAssets.capster1,
      rating: 4.6,
    ),
    BookingCapster(
      id: 'c2',
      name: 'Rangga P.',
      photoAsset: AppAssets.capster2,
      rating: 4.8,
    ),
    BookingCapster(
      id: 'c3',
      name: 'Bagas W.',
      photoAsset: AppAssets.capster3,
      rating: 4.5,
    ),
    BookingCapster(
      id: 'c4',
      name: 'Yoga S.',
      photoAsset: AppAssets.capster4,
      rating: 4.9,
    ),
  ];

  final List<BookingStore> _stores = List<BookingStore>.of(_seedStores);
  final List<BookingCapster> _capsters = List<BookingCapster>.of(_seedCapsters);

  List<BookingStore> get stores => List<BookingStore>.unmodifiable(_stores);
  List<BookingCapster> get capsters =>
      List<BookingCapster>.unmodifiable(_capsters);

  void addStore() {
    final int n = _stores.length + 1;
    _stores.add(
      BookingStore(
        id: 's$n-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Cabang Uji $n',
        address: 'Jl. Contoh Alamat Panjang No. $n, Kota Uji Coba',
        distanceKm: (n * 1.3) % 12,
        isLite: n.isEven,
      ),
    );
    notifyListeners();
  }

  void addCapster() {
    final int n = _capsters.length + 1;
    _capsters.add(
      BookingCapster(
        id: 'c$n-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Capster Uji $n',
        photoAsset: _capsterPhotos[n % _capsterPhotos.length],
        rating: 4 + (n % 10) / 10,
      ),
    );
    notifyListeners();
  }

  void removeLastStore() {
    if (_stores.isEmpty) return;
    _stores.removeLast();
    notifyListeners();
  }

  void removeLastCapster() {
    if (_capsters.isEmpty) return;
    _capsters.removeLast();
    notifyListeners();
  }

  void reset() {
    _stores
      ..clear()
      ..addAll(_seedStores);
    _capsters
      ..clear()
      ..addAll(_seedCapsters);
    notifyListeners();
  }
}
