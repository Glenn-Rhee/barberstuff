import 'package:tablet_dashboard/core/utils/json_value.dart';

enum TransactionType { income, outcome }

enum PaymentType {
  cash('cash', 'Tunai'),
  cashless('cashless', 'Non Tunai');

  const PaymentType(this.api, this.label);

  final String api;
  final String label;
}

// Satu transaksi di shift yang sedang buka
class CashTransaction {
  const CashTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.paymentType,
    this.description,
    this.createdAt,
    this.deletedAt,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) =>
      CashTransaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '-',
        amount: parseAmount(json['amount']),
        type: json['transaction_type'] == 'outcome'
            ? TransactionType.outcome
            : TransactionType.income,
        paymentType: PaymentType.values
            .where((p) => p.api == json['payment_type'])
            .firstOrNull,
        description: json['description'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')
            ?.toLocal(),
        deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? '')
            ?.toLocal(),
      );

  final String id;
  final String title;
  final int amount;
  final TransactionType type;
  final PaymentType? paymentType;
  final String? description;
  final DateTime? createdAt;

  // Waktu void, null = transaksi masih berlaku
  final DateTime? deletedAt;

  // Sudah di-void, tidak dihitung di total. [description] berisi alasannya
  bool get voided => deletedAt != null;
}
