import 'package:flutter/widgets.dart';

import '../../../../shared/models/person.dart';
import '../../../../shared/models/service_item.dart';
import '../../../dashboard/domain/cash_session.dart';

/// The walk-in order being rung up. Lives only on the tablet until it is paid,
/// then it becomes a booking plus a transaction on the server.
class OrderController extends ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Capster? capster;
  PaymentType method = PaymentType.cash;

  final Map<ServiceItem, int> _cart = {};

  List<CartLine> get lines => [for (final entry in _cart.entries) CartLine(entry.key, entry.value)];
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

  /// "Hapus Semua" and what runs after a successful payment.
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
