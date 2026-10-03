import 'dart:typed_data';

import 'package:tablet_dashboard/core/services/printer/esc_pos.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Pesanan yang sudah dibayar, dicetak di struk 58mm
class Receipt {
  const Receipt({
    required this.number,
    required this.createdAt,
    required this.cashier,
    required this.customer,
    required this.capster,
    required this.lines,
    required this.method,
    required this.cash,
    this.discount = 0,
  });

  static const storeName = 'BARBERSTUFF';
  static const storeTagline = 'Barbershop & Grooming';

  // Id booking berupa UUID, di struk dipendekkan
  static String numberFor(String bookingId) {
    final head = bookingId.replaceAll('-', '');
    return 'BK-${(head.length >= 8 ? head.substring(0, 8) : head).toUpperCase()}';
  }

  final String number;
  final DateTime createdAt;
  final String cashier;
  final String customer;
  final String capster;
  final List<CartLine> lines;
  final int discount;
  final PaymentType method;

  // Uang yang diterima, null saat cetak ulang (sudah dibayar)
  final int? cash;

  int get subtotal => lines.subtotal;
  int get total => subtotal - discount;
  int get change => (cash ?? total) - total;

  // [logo] dicetak di atas, tanpa logo pakai nama toko
  Uint8List toEscPos({RasterImage? logo}) {
    final pos = EscPos();
    if (logo != null) {
      pos
        ..raster(logo)
        ..feed();
    } else {
      pos.text(storeName, align: PosAlign.center, bold: true, large: true);
    }
    pos
      ..text(storeTagline, align: PosAlign.center)
      ..divider()
      ..row('No', number)
      ..row('Tanggal', DateFormatId.dateTime(createdAt))
      ..row('Kasir', cashier)
      ..row('Pelanggan', customer)
      ..row('Capster', capster)
      ..divider();
    for (final line in lines) {
      pos
        ..text(line.item.name)
        ..row(
          '  ${line.qty} x ${PriceFormat.plain(line.item.price)}',
          PriceFormat.plain(line.subtotal),
        );
    }
    pos
      ..divider()
      ..row('Subtotal', PriceFormat.full(subtotal));
    if (discount > 0) pos.row('Diskon', PriceFormat.full(-discount));
    pos.row('TOTAL', PriceFormat.full(total), bold: true);
    final cash = this.cash;
    if (cash != null && method == PaymentType.cash) {
      pos
        ..row('Tunai', PriceFormat.full(cash))
        ..row('Kembali', PriceFormat.full(change));
    } else if (cash != null) {
      pos.row(method.label, PriceFormat.full(total));
    }
    pos
      ..divider()
      ..text('Terima kasih!', align: PosAlign.center, bold: true)
      ..text('Sampai jumpa lagi', align: PosAlign.center)
      ..feed(4);
    return pos.build();
  }
}
