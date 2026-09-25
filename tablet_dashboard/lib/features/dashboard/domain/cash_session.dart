import '../../../shared/models/service_item.dart';

enum TransactionType { income, outcome }

enum PaymentType {
  cash('cash', 'Tunai'),
  cashless('cashless', 'Non Tunai');

  const PaymentType(this.api, this.label);

  final String api;
  final String label;
}

/// One entry of the open shift (`transactions` in `GET /cash-sessions`).
class CashTransaction {
  const CashTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.paymentType,
    this.description,
    this.createdAt,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) => CashTransaction(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '-',
    amount: ServiceItem.parsePrice(json['amount']),
    type: json['transaction_type'] == 'outcome' ? TransactionType.outcome : TransactionType.income,
    paymentType: PaymentType.values.where((p) => p.api == json['payment_type']).firstOrNull,
    description: json['description'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal(),
  );

  final String id;
  final String title;
  final int amount;
  final TransactionType type;
  final PaymentType? paymentType;
  final String? description;
  final DateTime? createdAt;
}

/// Today's open till (`GET /cash-sessions`). The backend calls the shift a cash session.
class CashSession {
  const CashSession({
    required this.id,
    required this.saldoBegin,
    required this.incomeCash,
    required this.incomeCashless,
    required this.outcome,
    required this.transactions,
  });

  factory CashSession.fromJson(Map<String, dynamic> json) => CashSession(
    id: json['id'] as String? ?? '',
    saldoBegin: ServiceItem.parsePrice(json['saldo_begin']),
    incomeCash: ServiceItem.parsePrice(json['total_income_cash']),
    incomeCashless: ServiceItem.parsePrice(json['total_income_cashless']),
    outcome: ServiceItem.parsePrice(json['total_outcome']),
    transactions: [
      for (final item in (json['transactions'] as List? ?? const []))
        if (item is Map) CashTransaction.fromJson(item.cast<String, dynamic>()),
    ],
  );

  final String id;
  final int saldoBegin;
  final int incomeCash;
  final int incomeCashless;
  final int outcome;
  final List<CashTransaction> transactions;

  int get income => incomeCash + incomeCashless;
  int get expectedCash => saldoBegin + incomeCash - outcome;

  Iterable<CashTransaction> get sales => transactions.where((t) => t.type == TransactionType.income);
  int get cashSales => sales.where((t) => t.paymentType == PaymentType.cash).length;
  int get cashlessSales => sales.where((t) => t.paymentType == PaymentType.cashless).length;
}
