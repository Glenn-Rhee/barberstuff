import 'package:tablet_dashboard/core/utils/json_value.dart';

// Satu shift yang sudah ditutup (GET /cash-sessions/history)
class CashHistoryEntry {
  const CashHistoryEntry({
    required this.id,
    required this.openingBalance,
    required this.actualCash,
    required this.incomeCash,
    required this.incomeCashless,
    required this.outcome,
    required this.openedAt,
    this.closedAt,
    this.storeName,
    this.staffName,
  });

  factory CashHistoryEntry.fromJson(Map<String, dynamic> json) {
    final store = (json['store'] as Map? ?? const {}).cast<String, dynamic>();
    final staff = (json['staff'] as Map? ?? const {}).cast<String, dynamic>();
    return CashHistoryEntry(
      id: json['id_cash_session'] as String? ?? '',
      openingBalance: parseAmount(json['saldo_begin']),
      actualCash: parseAmount(json['amount_actual']),
      incomeCash: parseAmount(json['total_income_cash']),
      incomeCashless: parseAmount(json['total_income_cashless']),
      outcome: parseAmount(json['total_outcome']),
      openedAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      closedAt: DateTime.tryParse(json['closed_at'] as String? ?? '')
          ?.toLocal(),
      storeName: store['name'] as String?,
      staffName: staff['name'] as String?,
    );
  }

  final String id;
  final int openingBalance;

  // Uang fisik yang dihitung kasir saat tutup shift
  final int actualCash;
  final int incomeCash;
  final int incomeCashless;
  final int outcome;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? storeName;
  final String? staffName;

  int get income => incomeCash + incomeCashless;

<<<<<<< HEAD
  // Non-tunai masuk rekening, tidak dihitung di laci.
  // Sama dengan rumus backend saat tutup kas (status di history backend
  // ikut menjumlah non-tunai, jadi dihitung ulang di sini)
=======
  // Uang laci: non-tunai tidak dihitung (rumus tutup kas backend)
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  int get expectedCash => openingBalance + incomeCash - outcome;
  int get difference => actualCash - expectedCash;

  String get statusLabel => switch (difference) {
    0 => 'Sesuai',
    > 0 => 'Lebih',
    _ => 'Kurang',
  };
}
