import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/local_list_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

enum ServiceSort {
  priceHigh('Harga Tertinggi'),
  priceLow('Harga Terendah'),
  name('Nama A-Z');

  const ServiceSort(this.label);

  final String label;
}

// Tab Service, paket di [PackageListController] supaya bisa berdampingan
class ServiceListController extends LocalListController<ServiceItem> {
  ServiceListController(
    this._api,
    this.storeId, {
    this.type = ServiceType.service,
  }) : super(pageSize: 5);

  final BranchApi _api;
  final String storeId;
  final ServiceType type;

  ServiceSort sort = ServiceSort.name;

  int get activeCount => all.where((s) => s.active).length;

  @override
  Future<List<ServiceItem>> fetch() => _api.services(storeId, type);

  @override
  bool accepts(ServiceItem item, String keyword) =>
      keyword.isEmpty ||
      item.name.toLowerCase().contains(keyword) ||
      (item.description?.toLowerCase().contains(keyword) ?? false);

  @override
  int compare(ServiceItem a, ServiceItem b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    final bySort = switch (sort) {
      ServiceSort.priceHigh => b.price.compareTo(a.price),
      ServiceSort.priceLow => a.price.compareTo(b.price),
      ServiceSort.name => 0,
    };
    return bySort != 0 ? bySort : byName;
  }

  void setSort(ServiceSort value) => change(() => sort = value);

  // Layanan baru selalu aktif (aturan backend)
  Future<String?> create({
    required String name,
    required int price,
    String? description,
  }) => mutate(
    () => _api.createService(
      storeId: storeId,
      type: type,
      name: name,
      price: price,
      description: description,
    ),
  );

  // Field null = tidak diubah
  Future<String?> update(
    ServiceItem item, {
    String? name,
    int? price,
    String? description,
    bool? active,
  }) => mutate(
    () => _api.updateService(
      item.id,
      name: name,
      price: price,
      description: description,
      active: active,
    ),
  );

  Future<String?> delete(ServiceItem item) =>
      mutate(() => _api.deleteService(item.id));
}

// Tab Paket di detail cabang
class PackageListController extends ServiceListController {
  PackageListController(super._api, super.storeId)
    : super(type: ServiceType.package);
}
