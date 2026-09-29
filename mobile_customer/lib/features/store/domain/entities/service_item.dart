enum ProductType { service, package }

/// Layanan satuan atau paket yang dijual sebuah cabang.
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.idStore,
    required this.type,
    required this.status,
    this.description,
  });

  final String id;
  final String name;
  final double price;
  final String idStore;
  final ProductType type;
  final String status;
  final String? description;

  bool get isActive => status.toLowerCase().trim() == 'active';
}
