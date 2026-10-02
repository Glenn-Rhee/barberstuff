import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Layanan, paket, dan capster satu toko
class CatalogApi {
  const CatalogApi(this._client);

  final ApiClient _client;

  Future<Paged<ServiceItem>> services({
    required String storeId,
    required ServiceType type,
    String? name,
    int page = 1,
    int limit = 12,
  }) async {
    final res = await _client.get(
      '/service/',
      query: {
        'id_store': storeId,
        'type': type.api,
        'name': name,
        'page': page,
        'limit': limit,
      },
    );
    return Paged(
      items: [for (final json in res.list) ServiceItem.fromJson(json)],
      totalPages: res.totalPages,
      totalData: res.totalData,
    );
  }

  Future<List<Capster>> capsters(String storeId) async {
    final res = await _client.get(
      '/capster/',
      query: {'id_store': storeId, 'limit': 50},
    );
    return [for (final json in res.list) Capster.fromJson(json)];
  }
}
