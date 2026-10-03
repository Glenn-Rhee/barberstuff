import 'package:mobile_barberstuff/core/utils/json_value.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';

class ServiceItemModel extends ServiceItem {
  const ServiceItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.idStore,
    required super.type,
    required super.status,
    super.description,
  });

  static ProductType typeFromJson(String? value) {
    return value?.toLowerCase().trim() == 'package'
        ? ProductType.package
        : ProductType.service;
  }

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: jsonText(json['id']),
      name: jsonText(json['name'] ?? json['string']),
      price: jsonDouble(json['price']),
      idStore: jsonText(json['id_store']),
      type: typeFromJson(json['type'] as String?),
      status: jsonText(json['status']),
      description: json['description'] as String?,
    );
  }
}
