import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_capsters.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';

enum StoreTab { about, service, package, review }

class StoreDetailProvider extends ChangeNotifier {
  StoreDetailProvider(
    this._getDetail,
    this._getCapsters,
    this._getServices,
    this.storeId, {
    StoreTab initialTab = StoreTab.about,
  }) : _tab = initialTab {
    load();
    // Tab selain Tentang perlu tarik produknya sendiri, setTab tidak jalan
    // karena tabnya memang sudah terpilih sejak awal.
    if (initialTab == StoreTab.service) _loadProducts(ProductType.service);
    if (initialTab == StoreTab.package) _loadProducts(ProductType.package);
  }

  final GetStoreDetail _getDetail;
  final GetStoreCapsters _getCapsters;
  final GetStoreServices _getServices;
  final String storeId;

  StoreDetail? _detail;
  List<CapsterItem> _capsters = const <CapsterItem>[];
  final Map<ProductType, List<ServiceItem>> _products =
      <ProductType, List<ServiceItem>>{};

  StoreTab _tab;
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  ApiException? _error;

  StoreDetail? get detail => _detail;
  List<CapsterItem> get capsters => _capsters;
  StoreTab get tab => _tab;
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  ApiException? get error => _error;

  List<ServiceItem> get services =>
      _products[ProductType.service] ?? const <ServiceItem>[];
  List<ServiceItem> get packages =>
      _products[ProductType.package] ?? const <ServiceItem>[];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _detail = await _getDetail(storeId);
    } on ApiException catch (e) {
      _error = e;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _capsters = await _getCapsters(storeId);
    } on ApiException catch (_) {
      _capsters = const <CapsterItem>[];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setTab(StoreTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();

    if (value == StoreTab.service) _loadProducts(ProductType.service);
    if (value == StoreTab.package) _loadProducts(ProductType.package);
  }

  Future<void> _loadProducts(ProductType type) async {
    if (_products.containsKey(type)) return;

    _isLoadingProducts = true;
    notifyListeners();

    try {
      _products[type] = await _getServices(
        GetStoreServicesParams(storeId: storeId, type: type),
      );
    } on ApiException catch (_) {
      _products[type] = const <ServiceItem>[];
    }

    _isLoadingProducts = false;
    notifyListeners();
  }
}
