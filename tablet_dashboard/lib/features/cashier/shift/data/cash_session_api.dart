import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/paged.dart';
import 'package:tablet_dashboard/core/utils/json_value.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Shift (cash session) dan uang yang keluar masuk di dalamnya
class CashSessionApi {
  const CashSessionApi(this._client);

  final ApiClient _client;

  // Shift yang sedang buka, null kalau belum ada
  Future<CashSession?> cashSession() async {
    try {
      return CashSession.fromJson((await _client.get('/cash-sessions/')).map);
    } on ApiException catch (e) {
      // 400 / 404 = "Transaksi pembukuan telah ditutup."
      if (e.statusCode == 400 || e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<String> openCashSession(int openingBalance) async {
    final res = await _client.post(
      '/cash-sessions/',
      data: {'saldo_begin': openingBalance},
    );
    return res.map['id'] as String? ?? '';
  }

  // Balikin selisih uang hitung vs hitungan sistem
  Future<({int difference, String status})> closeCashSession({
    required String sessionId,
    required int amountActual,
  }) async {
    final res = await _client.patch(
      '/cash-sessions/',
      data: {'id_cash_session': sessionId, 'amount_actual': amountActual},
    );
    return (
      difference: parseAmount(res.map['amount_difference']),
      status: res.map['status'] as String? ?? '',
    );
  }

  // Shift yang sudah ditutup di bulan [month], terbaru dulu.
  // [storeId] wajib untuk admin, role lain pakai toko akun
  Future<Paged<CashHistoryEntry>> history({
    required DateTime month,
    String? query,
    String? storeId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _client.get(
      '/cash-sessions/history',
      query: {
        'date': DateTime.utc(month.year, month.month, 15).toIso8601String(),
        'q': query,
        'id_store': storeId,
        'page': page,
        'limit': limit,
      },
    );
    return Paged.fromPage(
      [for (final json in res.list) CashHistoryEntry.fromJson(json)],
      page: page,
      limit: limit,
    );
  }

  Future<void> createTransaction({
    required String sessionId,
    required TransactionType type,
    required int amount,
    PaymentType? paymentType,
    String? title,
    String? description,
    String? bookingId,
  }) {
    return _client.post(
      '/transactions/',
      data: {
        'id_cash_session': sessionId,
        'transaction_type': type.name,
        'amount': amount,
        'payment_type': ?paymentType?.api,
        'title': ?title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'id_booking': ?bookingId,
      },
    );
  }
}
