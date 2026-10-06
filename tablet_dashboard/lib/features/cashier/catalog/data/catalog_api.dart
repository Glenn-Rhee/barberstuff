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
    return Paged.fromPage(
      [for (final json in res.list) ServiceItem.fromJson(json)],
      page: page,
      limit: limit,
    );
  }

  Future<List<Capster>> capsters(String storeId) async {
    final res = await _client.get(
      '/capster/',
      query: {'id_store': storeId, 'limit': 50},
    );
    return [for (final json in res.list) Capster.fromJson(json)];
  }

  // Aktif / nonaktifkan capster. Backend saat ini hanya izinkan admin
  Future<void> setCapsterActive(String id, {required bool active}) => _client
      .patch('/capster/$id', data: {'status': active ? 'active' : 'inactive'});
}
