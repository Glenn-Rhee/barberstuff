import 'package:tablet_dashboard/core/utils/json_value.dart';

enum ServiceType {
  service('service', 'Service'),
  package('package', 'Paket'),
  produk('produk', 'Produk');

  const ServiceType(this.api, this.label);

  // Nilai service.type di backend
  final String api;
  final String label;

  static ServiceType parse(String? value) =>
      values.where((t) => t.api == value).firstOrNull ?? ServiceType.service;
}

// Layanan / paket yang dijual toko (GET /service)
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.type = ServiceType.service,
    this.active = true,
  });

  // Endpoint list kirim nama di field "string"
  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    id: json['id'] as String,
    name: (json['string'] ?? json['name'] ?? '-') as String,
    price: parseAmount(json['price']),
    description: json['description'] as String?,
    type: ServiceType.parse(json['type'] as String?),
    active: (json['status'] as String? ?? 'active') == 'active',
  );

  final String id;
  final String name;
  final int price;
  final String? description;
  final ServiceType type;

  // Status dari admin (active / inactive)
  final bool active;

  @override
  bool operator ==(Object other) => other is ServiceItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
