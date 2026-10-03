import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tablet_dashboard/core/services/printer/esc_pos.dart';
import 'package:tablet_dashboard/core/services/printer/test_print.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

import 'escpos_decoder.dart';

const cut = ServiceItem(id: 'SVC-1', name: 'Classic Hair Cut', price: 45000);
const color = ServiceItem(id: 'SVC-2', name: 'Black Hair Color', price: 120000);

Receipt receipt({
  PaymentType method = PaymentType.cash,
  int? cash = 300000,
  int discount = 10000,
}) => Receipt(
  number: 'BK-0123ABCD',
  createdAt: DateTime(2026, 9, 24, 14, 5),
  cashier: 'Wibawa Mukti',
  customer: 'Iqbal Apriand',
  capster: 'Wahyu',
  lines: const [CartLine(cut), CartLine(color, 2)],
  discount: discount,
  method: method,
  cash: cash,
);

void main() {
  test('format harga dan tanggal Indonesia', () {
    expect(PriceFormat.plain(1250000), '1.250.000');
    expect(PriceFormat.full(-10000), '-Rp 10.000');
    expect(PriceFormat.short(185000), '185k');
    expect(DateFormatId.longDate(DateTime(2024, 5, 27)), 'Senin, 27 Mei 2024');
    expect(
      DateFormatId.dateTime(DateTime(2026, 9, 24, 8, 5)),
      '24/09/2026 08:05',
    );
  });

  test('ServiceItem membaca bentuk data API', () {
    final item = ServiceItem.fromJson({
      'id': 'abc',
      'string': 'Bleaching', // endpoint list kirim nama di "string"
      'price': '250000',
      'type': 'package',
      'description': null,
    });
    expect(item.name, 'Bleaching');
    expect(item.price, 250000);
    expect(item.type, ServiceType.package);
  });

  test('EscPos isi baris jadi 32 kolom dan pecah yang kepanjangan', () {
    final bytes = (EscPos()..row('TOTAL', 'Rp 50.000')).build();
    expect(bytes.sublist(0, 2), [0x1B, 0x40]);
    expect(decodeEscPos(bytes).single.text, row('TOTAL', 'Rp 50.000'));

    final wrapped = decodeEscPos(
      (EscPos()..row('A' * 25, 'Rp 150.000')).build(),
    );
    expect(wrapped.map((l) => l.text), ['A' * 25, 'Rp 150.000']);
  });

  test('EscPos ganti karakter non-ASCII', () {
    expect(
      decodeEscPos((EscPos()..text('Café · ok')).build()).single.text,
      'Caf? ? ok',
    );
  });

  test('gambar raster dikirim sebagai GS v 0, 1 bit per titik', () {
    final logo = RasterImage(
      width: 16,
      height: 2,
      bits: Uint8List.fromList([0xFF, 0x00, 0x0F, 0xF0]),
    );
    final bytes = (EscPos()..raster(logo)).build();
    // ESC @, ESC a 1 (tengah), lalu GS v 0 m xL xH yL yH
    expect(bytes.sublist(2, 13), [
      0x1B,
      0x61,
      0x01,
      0x1D,
      0x76,
      0x30,
      0x00,
      0x02,
      0x00,
      0x02,
      0x00,
    ]);
    expect(bytes.sublist(13, 17), [0xFF, 0x00, 0x0F, 0xF0]);
  });

  test('struk tunai muat di kertas 58mm dan totalnya benar', () {
    final r = receipt();
    expect(r.subtotal, 285000);
    expect(r.total, 275000);
    expect(r.change, 25000);

    final lines = decodeEscPos(r.toEscPos());
    for (final line in lines) {
      expect(
        line.text.length,
        lessThanOrEqualTo(line.maxWidth),
        reason: '"${line.text}" kelebaran',
      );
    }
    final text = lines.map((l) => l.text).toList();
    expect(text.first, 'BARBERSTUFF');
    expect(text, contains(row('No', 'BK-0123ABCD')));
    expect(text, contains(row('Kasir', 'Wibawa Mukti')));
    expect(text, contains(row('Capster', 'Wahyu')));
    expect(text, contains(row('  2 x 120.000', '240.000')));
    expect(text, contains(row('Diskon', '-Rp 10.000')));
    expect(text, contains(row('TOTAL', 'Rp 275.000')));
    expect(text, contains(row('Kembali', 'Rp 25.000')));
  });

  test('struk non tunai tanpa baris kembalian', () {
    final text = decodeEscPos(
      receipt(method: PaymentType.cashless, cash: 275000).toEscPos(),
    ).map((l) => l.text).toList();
    expect(text, contains(row('Non Tunai', 'Rp 275.000')));
    expect(text.where((l) => l.startsWith('Kembali')), isEmpty);
  });

  test('cetak ulang tanpa baris pembayaran', () {
    final text = decodeEscPos(receipt(cash: null).toEscPos())
        .map((l) => l.text)
        .toList();
    expect(text, contains(row('TOTAL', 'Rp 275.000')));
    expect(
      text.where((l) => l.startsWith('Tunai') || l.startsWith('Kembali')),
      isEmpty,
    );
  });

  test('halaman test print muat di kertas 58mm', () {
    final lines = decodeEscPos(
      buildTestPrint(printerName: 'RPP210A', now: DateTime(2026, 9, 24)),
    );
    for (final line in lines) {
      expect(
        line.text.length,
        lessThanOrEqualTo(line.maxWidth),
        reason: '"${line.text}" kelebaran',
      );
    }
    expect(
      lines.map((l) => l.text),
      contains('12345678901234567890123456789012'),
    );
  });

  test('nomor struk memendekkan uuid booking', () {
    expect(
      Receipt.numberFor('9fd21e72-236d-493e-b258-b80d668b404e'),
      'BK-9FD21E72',
    );
    expect(Receipt.numberFor('abc'), 'BK-ABC');
  });
}
