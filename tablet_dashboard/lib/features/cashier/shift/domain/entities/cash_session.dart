import 'package:tablet_dashboard/core/utils/json_value.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Shift kasir hari ini (GET /cash-sessions), di backend namanya cash session
class CashSession {
  const CashSession({
    required this.id,
    required this.openingBalance,
    required this.incomeCash,
    required this.incomeCashless,
    required this.outcome,
    required this.transactions,
  });

  factory CashSession.fromJson(Map<String, dynamic> json) => CashSession(
    id: json['id'] as String? ?? '',
    openingBalance: parseAmount(json['saldo_begin']),
    incomeCash: parseAmount(json['total_income_cash']),
    incomeCashless: parseAmount(json['total_income_cashless']),
    outcome: parseAmount(json['total_outcome']),
    transactions: [
      for (final item in (json['transactions'] as List? ?? const []))
        if (item is Map) CashTransaction.fromJson(item.cast<String, dynamic>()),
    ],
  );

  final String id;
  final int openingBalance;
  final int incomeCash;
  final int incomeCashless;
  final int outcome;
  final List<CashTransaction> transactions;

  int get income => incomeCash + incomeCashless;
  int get expectedCash => openingBalance + incomeCash - outcome;

  Iterable<CashTransaction> get sales =>
      transactions.where((t) => t.type == TransactionType.income);
  int get cashSales =>
      sales.where((t) => t.paymentType == PaymentType.cash).length;
  int get cashlessSales =>
      sales.where((t) => t.paymentType == PaymentType.cashless).length;
}
