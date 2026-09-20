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
      id: 'ciracas',
      name: 'Ciracas',
      address:
          'Jl. Raya Centex No.1, RT.5/RW.10, Ciracas, Kec. Ciracas, '
          'Kota Jakarta Timur, Daerah Khusus Ibukota Jakarta 13740',
      distanceKm: 0.6,
      imageAsset: AppAssets.storeCiracas,
      rating: 4.8,
      isNewbie: true,
    ),
    BookingStore(
      id: 'depok',
      name: 'Depok',
      address:
          'Jl. Tole Iskandar, Mekar Jaya, Kec. Sukmajaya, Kota Depok, '
          'Jawa Barat 16412',
      distanceKm: 3.2,
      imageAsset: AppAssets.storeDepok,
      rating: 4.7,
    ),
    BookingStore(
      id: 'jimbaran',
      name: 'Bali Jimbaran',
      address:
          'Jl. Rumah Sakit Unud, Jimbaran, Kec. Kuta Sel., '
          'Kabupaten Badung, Bali 80361',
      distanceKm: 12.4,
      imageAsset: AppAssets.storeBatujimbaran,
      rating: 4.9,
      isNewbie: true,
    ),
    BookingStore(
      id: 'pondokgede',
      name: 'Pondok Gede',
      address:
          'Gg. Leopard Jl. Jatimakmur No.49C, RT.001/RW.011, Jatimakmur, '
          'Kec. Pd. Gede, Kota Bekasi, Jawa Barat 17413',
      distanceKm: 5.1,
      imageAsset: AppAssets.storePondokgede,
      rating: 4.6,
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

  static const List<BookingService> _seedServices = <BookingService>[
    BookingService(
      id: 'sv1',
      name: 'Potong Rambut',
      description: 'Potong rambut standar',
      price: 95000,
      kind: ServiceKind.single,
    ),
    BookingService(
      id: 'sv2',
      name: 'Potong Rambut - Premium',
      description: 'Potong rambut standar + cuci rambut',
      price: 135000,
      kind: ServiceKind.single,
    ),
    BookingService(
      id: 'sv3',
      name: 'Potong Rambut - Exclusive',
      description: 'Potong rambut standar + cuci rambut + pijat',
      price: 175000,
      kind: ServiceKind.single,
    ),
    BookingService(
      id: 'pk1',
      name: 'Mythical',
      description: 'Potong rambut standar, cuci rambut, & pijat ringan',
      price: 95000,
      kind: ServiceKind.package,
    ),
    BookingService(
      id: 'pk2',
      name: 'Legend',
      description: 'Haircut Classic + shaving kumis/jenggot + hot towel',
      price: 135000,
      kind: ServiceKind.package,
    ),
    BookingService(
      id: 'pk3',
      name: 'Immortal',
      description: 'Haircut Classic + shaving kumis/jenggot + hot towel',
      price: 185000,
      kind: ServiceKind.package,
    ),
  ];

  final List<BookingStore> _stores = List<BookingStore>.of(_seedStores);
  final List<BookingCapster> _capsters = List<BookingCapster>.of(_seedCapsters);
  final List<BookingService> _services = List<BookingService>.of(_seedServices);

  ReceiptCodeType _codeType = ReceiptCodeType.barcode;

  List<BookingStore> get stores => List<BookingStore>.unmodifiable(_stores);
  List<BookingCapster> get capsters =>
      List<BookingCapster>.unmodifiable(_capsters);
  List<BookingService> get services =>
      List<BookingService>.unmodifiable(_services);

  List<BookingService> servicesOf(ServiceKind kind) =>
      _services.where((BookingService s) => s.kind == kind).toList();

  ReceiptCodeType get codeType => _codeType;

  void setCodeType(ReceiptCodeType value) {
    if (_codeType == value) return;
    _codeType = value;
    notifyListeners();
  }

  void addStore() {
    final int n = _stores.length + 1;
    _stores.add(
      BookingStore(
        id: 'store-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Cabang Uji $n',
        address: 'Jl. Contoh Alamat Panjang No. $n, Kota Uji Coba',
        distanceKm: (n * 1.3) % 12,
        imageAsset: _seedStores[n % _seedStores.length].imageAsset,
        rating: 4 + (n % 10) / 10,
        isNewbie: n.isEven,
      ),
    );
    notifyListeners();
  }

  void addCapster() {
    final int n = _capsters.length + 1;
    _capsters.add(
      BookingCapster(
        id: 'capster-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Capster Uji $n',
        photoAsset: _capsterPhotos[n % _capsterPhotos.length],
        rating: 4 + (n % 10) / 10,
      ),
    );
    notifyListeners();
  }

  void addService(ServiceKind kind) {
    final int n =
        _services.where((BookingService s) => s.kind == kind).length + 1;
    final String label = kind == ServiceKind.single ? 'Jasa' : 'Paket';
    _services.add(
      BookingService(
        id: 'service-${DateTime.now().microsecondsSinceEpoch}',
        name: '$label Uji $n',
        description: 'Deskripsi $label uji coba nomor $n',
        price: 50000 + n * 15000,
        kind: kind,
      ),
    );
    notifyListeners();
  }

  void updateService(
    String id, {
    String? name,
    String? description,
    int? price,
  }) {
    final int index = _services.indexWhere((BookingService s) => s.id == id);
    if (index < 0) return;
    _services[index] = _services[index].copyWith(
      name: name,
      description: description,
      price: price,
    );
    notifyListeners();
  }

  void removeService(String id) {
    _services.removeWhere((BookingService s) => s.id == id);
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
    _services
      ..clear()
      ..addAll(_seedServices);
    _codeType = ReceiptCodeType.barcode;
    notifyListeners();
  }
}
