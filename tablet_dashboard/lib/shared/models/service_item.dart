enum ServiceType {
  service('service', 'Service'),
  package('package', 'Paket');

  const ServiceType(this.api, this.label);

  /// Value the backend uses for `service.type`.
  final String api;
  final String label;

  static ServiceType parse(String? value) => values.where((t) => t.api == value).firstOrNull ?? ServiceType.service;
}

/// A service or package sold by one store (`GET /service`).
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.type = ServiceType.service,
  });

  /// The list endpoint returns the name in a field called `string`.
  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    id: json['id'] as String,
    name: (json['string'] ?? json['name'] ?? '-') as String,
    price: parsePrice(json['price']),
    description: json['description'] as String?,
    type: ServiceType.parse(json['type'] as String?),
  );

  final String id;
  final String name;
  final int price;
  final String? description;
  final ServiceType type;

  /// Prices arrive as `"120000"` or `120000`.
  static int parsePrice(Object? value) => switch (value) {
    num() => value.round(),
    String() => (num.tryParse(value) ?? 0).round(),
    _ => 0,
  };

  @override
  bool operator ==(Object other) => other is ServiceItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CartLine {
  const CartLine(this.item, [this.qty = 1]);

  final ServiceItem item;
  final int qty;

  int get subtotal => item.price * qty;
}

extension CartLinesTotal on Iterable<CartLine> {
  int get subtotal => fold(0, (sum, line) => sum + line.subtotal);
}
