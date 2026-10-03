import 'package:flutter/widgets.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Pesanan langsung yang sedang diinput.
// Aturan keranjang: boleh lebih dari 1 item, campur service & paket,
// tapi item yang sama cuma 1x (tidak bisa cukur 2x)
class OrderController extends ChangeNotifier {
  // Batas no HP dari backend
  static const minPhone = 9;
  static const maxPhone = 15;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Pelanggan dari histori, null = pelanggan baru (isi nama + no HP)
  CustomerProfile? customer;
  Capster? capster;
  PaymentType method = PaymentType.cash;

  final List<ServiceItem> _items = [];

  List<ServiceItem> get items => List.unmodifiable(_items);
  List<CartLine> get lines => [for (final item in _items) CartLine(item)];
  bool get isEmpty => _items.isEmpty;
  bool contains(ServiceItem item) => _items.contains(item);
  int get total => lines.subtotal;

  String get customerName {
    final selected = customer;
    if (selected != null) return selected.name;
    final name = nameController.text.trim();
    return name.isEmpty ? 'Pelanggan' : name;
  }

  String get customerPhone => customer?.phone ?? phoneController.text.trim();

  // Pesan kalau data pelanggan belum lengkap, null = siap dikirim
  String? get customerError {
    if (customer != null) return null;
    if (nameController.text.trim().isEmpty) return 'Isi nama pelanggan dulu';
    final digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < minPhone || digits.length > maxPhone) {
      return 'Nomor telepon harus $minPhone-$maxPhone digit';
    }
    return null;
  }

  void add(ServiceItem item) {
    if (_items.contains(item)) return;
    _items.add(item);
    notifyListeners();
  }

  void remove(ServiceItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void setCustomer(CustomerProfile value) {
    customer = value;
    nameController.clear();
    phoneController.clear();
    notifyListeners();
  }

  void clearCustomer() {
    customer = null;
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

  // Ketik nama / no HP ikut memperbarui tombol simpan & bayar
  void touch() => notifyListeners();

  // "Hapus Semua", juga dipanggil setelah pesanan tersimpan / dibayar
  void clearAll() {
    _items.clear();
    customer = null;
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
