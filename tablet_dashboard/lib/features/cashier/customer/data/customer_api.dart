import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';

// Histori pelanggan semua cabang. Pelanggan tanpa aplikasi otomatis
// tersimpan oleh backend saat kasir membuat pesanan (nama + no HP)
class CustomerApi {
  const CustomerApi(this._client);

  final ApiClient _client;

  // q dicocokkan ke nama (sebagian), no HP / email / id (harus persis)
  Future<Paged<CustomerProfile>> customers({
    String? query,
    int page = 1,
    int limit = 12,
  }) async {
    final res = await _client.get(
      '/customer/',
      query: {
        'q': query,
        'page': page,
        'limit': limit,
        'sort_by': 'created_at',
        'order': 'desc',
      },
    );
    final list = res.map['customers'] as List? ?? const [];
    return Paged.fromPage(
      [
        for (final json in list)
          if (json is Map) CustomerProfile.fromJson(json.cast()),
      ],
      page: page,
      limit: limit,
    );
  }
}
