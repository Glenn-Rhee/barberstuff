import 'package:flutter_test/flutter_test.dart';
import 'package:tablet_dashboard/core/printer/receipt_logo.dart';
import 'package:tablet_dashboard/features/cashier/domain/receipt.dart';
import 'package:tablet_dashboard/features/dashboard/domain/cash_session.dart';
import 'package:tablet_dashboard/shared/models/service_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the splash wordmark becomes a printable 1-bit bitmap', () async {
    final logo = await ReceiptLogo.load();
    expect(logo, isNotNull, reason: 'asset ${ReceiptLogo.asset} should decode');

    // 928x269 artwork scaled to the 320 dot print width.
    expect(logo!.width, ReceiptLogo.printWidth);
    expect(logo.bytesPerRow, 40);
    expect(logo.height, closeTo(269 * 320 / 928, 2));
    expect(logo.bits.length, logo.bytesPerRow * logo.height);

    final ink = logo.bits.fold(0, (sum, byte) => sum + byte.toRadixString(2).replaceAll('0', '').length);
    expect(ink, greaterThan(logo.width * logo.height ~/ 20), reason: 'wordmark should have ink');

    // ignore: avoid_print
    print(_preview(logo.bits, logo.width, logo.height));
  });

  test('receipt prints the logo bitmap instead of the store name', () async {
    final logo = await ReceiptLogo.load();
    final receipt = Receipt(
      number: 'BK-1',
      createdAt: DateTime(2026, 9, 24, 14, 5),
      cashier: 'Wibawa Mukti',
      customer: 'Iqbal Apriand',
      capster: 'Wahyu',
      lines: const [CartLine(ServiceItem(id: 'SVC-1', name: 'Classic Hair Cut', price: 45000))],
      method: PaymentType.cash,
      cash: 50000,
    );

    final withLogo = receipt.toEscPos(logo: logo);
    // GS v 0 right after the ESC @ reset and the centre alignment.
    expect(withLogo.sublist(5, 8), [0x1D, 0x76, 0x30]);
    expect(withLogo.length, greaterThan(receipt.toEscPos().length));
  });
}

/// Renders the packed bitmap as text so the logo can be checked in test output.
String _preview(List<int> bits, int width, int height, {int cols = 64, int rows = 16}) {
  final bytesPerRow = width ~/ 8;
  final buffer = StringBuffer();
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final x = col * width ~/ cols;
      final y = row * height ~/ rows;
      final on = bits[y * bytesPerRow + (x >> 3)] & (0x80 >> (x & 7)) != 0;
      buffer.write(on ? '#' : '.');
    }
    buffer.writeln();
  }
  return buffer.toString();
}
