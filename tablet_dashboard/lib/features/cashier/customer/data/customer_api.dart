import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_kpi.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';

// Satu halaman GET /customer + angka ringkasannya
class CustomerPage extends Paged<CustomerProfile> {
  const CustomerPage({
    required super.items,
    required super.totalPages,
    required super.totalData,
    required this.kpi,
  });

  final CustomerKpi kpi;
}

// Histori pelanggan semua cabang. Pelanggan tanpa aplikasi otomatis
// tersimpan oleh backend saat kasir membuat pesanan (nama + no HP)
class CustomerApi {
  const CustomerApi(this._client);

  final ApiClient _client;

  // q dicocokkan ke nama (sebagian), no HP / email / id (harus persis).
  // Urut dari pelanggan terbaru
  Future<CustomerPage> customers({
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
    final paged = Paged.fromPage(
      [
        for (final json in list)
          if (json is Map) CustomerProfile.fromJson(json.cast()),
      ],
      page: page,
      limit: limit,
    );
    return CustomerPage(
      items: paged.items,
      totalPages: paged.totalPages,
      totalData: paged.totalData,
      kpi: CustomerKpi.fromJson(
        (res.map['kpi'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
    );
  }
}
