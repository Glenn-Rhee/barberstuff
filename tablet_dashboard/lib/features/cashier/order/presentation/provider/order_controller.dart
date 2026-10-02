import 'package:flutter/widgets.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Pesanan langsung yang sedang diinput. Hanya ada di tablet sampai dibayar,
// setelah itu jadi booking + transaksi di server
class OrderController extends ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Capster? capster;
  PaymentType method = PaymentType.cash;

  final Map<ServiceItem, int> _cart = {};

  List<CartLine> get lines => [
    for (final entry in _cart.entries) CartLine(entry.key, entry.value),
  ];
  bool get isEmpty => _cart.isEmpty;
  int qtyOf(ServiceItem item) => _cart[item] ?? 0;
  int get total => lines.subtotal;

  String get customerName {
    final name = nameController.text.trim();
    return name.isEmpty ? 'Pelanggan Umum' : name;
  }

  String get customerPhone => phoneController.text.trim();

  void add(ServiceItem item) {
    _cart[item] = qtyOf(item) + 1;
    notifyListeners();
  }

  void remove(ServiceItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void setCapster(Capster value) {
    capster = value;
    notifyListeners();
  }

  void setMethod(PaymentType value) {
    method = value;
    notifyListeners();
  }

  // "Hapus Semua", juga dipanggil setelah bayar berhasil
  void clearAll() {
    _cart.clear();
    capster = null;
    method = PaymentType.cash;
    nameController.clear();
    phoneController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
