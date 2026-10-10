import 'package:flutter/widgets.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/discount.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Pesanan langsung: boleh banyak item, item yang sama boleh lebih dari 1x
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

  // Diskon manual kasir, baru dikirim ke server saat bayar
  Discount? discount;

  // Layanan + jumlahnya, urut sesuai waktu ditambah
  final Map<ServiceItem, int> _qty = {};

  List<CartLine> get lines => [
    for (final MapEntry(:key, :value) in _qty.entries) CartLine(key, value),
  ];
  bool get isEmpty => _qty.isEmpty;
  bool contains(ServiceItem item) => _qty.containsKey(item);
  int get subtotal => lines.subtotal;
  int get discountAmount => discount?.amountFor(subtotal) ?? 0;
  int get total => subtotal - discountAmount;

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
    if (_qty.containsKey(item)) return;
    _qty[item] = 1;
    notifyListeners();
  }

  // Tombol "+" di keranjang
  void increment(ServiceItem item) {
    _qty.update(item, (qty) => qty + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  // Tombol sampah di keranjang: -1, sisa 1 = keluar dari keranjang
  void decrement(ServiceItem item) {
    final qty = _qty[item];
    if (qty == null) return;
    if (qty <= 1) {
      _qty.remove(item);
    } else {
      _qty[item] = qty - 1;
    }
    notifyListeners();
  }

  void remove(ServiceItem item) {
    _qty.remove(item);
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

  // null = hapus diskon
  void setDiscount(Discount? value) {
    discount = value;
    notifyListeners();
  }

  // Ketik nama / no HP ikut memperbarui tombol simpan & bayar
  void touch() => notifyListeners();

  // "Hapus Semua", juga dipanggil setelah pesanan tersimpan / dibayar
  void clearAll() {
    _qty.clear();
    customer = null;
    capster = null;
    method = PaymentType.cash;
    discount = null;
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
