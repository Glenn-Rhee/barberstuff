import 'package:tablet_dashboard/core/utils/price_format.dart';

enum DiscountType {
  percent('Percent %'),
  nominal('Nominal Rp');

  const DiscountType(this.label);

  final String label;
}

<<<<<<< HEAD
// Diskon manual kasir. Backend cuma terima nominal (discount_amount),
// jadi persen diubah ke rupiah dari total yang dibayar
=======
// Diskon kasir. Backend cuma terima nominal, persen diubah ke rupiah
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
class Discount {
  const Discount(this.type, this.value);

  final DiscountType type;
  final int value;

  bool get isPercent => type == DiscountType.percent;

  // Potongan rupiah untuk [total], tidak pernah lebih dari total
  int amountFor(int total) {
    final amount = isPercent ? total * value ~/ 100 : value;
    return amount.clamp(0, total < 0 ? 0 : total);
  }

  // Label baris ringkasan, mis. "Diskon Produk (10%)"
  String get summaryLabel =>
      isPercent ? 'Diskon Produk ($value%)' : 'Diskon Produk';

  // "10%" atau "Rp 5.000"
  String get label => isPercent ? '$value%' : PriceFormat.full(value);

  // Pesan kalau tidak bisa diterapkan ke [total], null = boleh
  String? errorFor(int total) {
    if (value <= 0) return 'Isi jumlah diskon';
    if (isPercent && value > 100) return 'Diskon maksimal 100%';
    if (!isPercent && value > total) {
      return 'Diskon melebihi total ${PriceFormat.full(total)}';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is Discount && other.type == type && other.value == value;

  @override
  int get hashCode => Object.hash(type, value);
}
