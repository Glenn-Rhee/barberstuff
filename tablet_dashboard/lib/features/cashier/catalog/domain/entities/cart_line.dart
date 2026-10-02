import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Satu baris keranjang: layanan dan jumlahnya
class CartLine {
  const CartLine(this.item, [this.qty = 1]);

  final ServiceItem item;
  final int qty;

  int get subtotal => item.price * qty;
}

extension CartLinesTotal on Iterable<CartLine> {
  int get subtotal => fold(0, (sum, line) => sum + line.subtotal);
}
