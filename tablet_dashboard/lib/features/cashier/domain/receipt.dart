import 'dart:typed_data';

import '../../../core/printer/esc_pos.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/price_format.dart';
import '../../../shared/models/service_item.dart';
import '../../dashboard/domain/cash_session.dart';

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

  final String number;
  final DateTime createdAt;
  final String cashier;
  final String customer;
  final String capster;
  final List<CartLine> lines;
  final int discount;
  final PaymentType method;

  /// Money handed over; `null` on a reprint, where the payment is already done.
  final int? cash;

  int get subtotal => lines.subtotal;
  int get total => subtotal - discount;
  int get change => (cash ?? total) - total;

  /// [logo] prints the Barberstuff wordmark on top; without it the name is printed as text.
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
        ..row('  ${line.qty} x ${PriceFormat.plain(line.item.price)}', PriceFormat.plain(line.subtotal));
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

/// A page that checks width, bold, alignment, large text and the logo bitmap in one go.
Uint8List buildTestPrint({required String printerName, required DateTime now, RasterImage? logo}) {
  final pos = EscPos();
  if (logo != null) {
    pos
      ..raster(logo)
      ..feed();
  }
  pos
    ..text('TEST PRINT', align: PosAlign.center, bold: true, large: true)
    ..text('Barberstuff Kasir', align: PosAlign.center)
    ..divider()
    ..row('Printer', printerName)
    ..row('Waktu', DateFormatId.dateTime(now))
    ..row('Kertas', '58mm / 32 kolom')
    ..divider()
    ..text('12345678901234567890123456789012')
    ..text('Teks normal')
    ..text('Teks tebal', bold: true)
    ..text('Rata tengah', align: PosAlign.center)
    ..text('Rata kanan', align: PosAlign.right)
    ..text('BESAR', align: PosAlign.center, large: true)
    ..divider('=')
    ..text('Printer siap dipakai!', align: PosAlign.center, bold: true)
    ..feed(4);
  return pos.build();
}
