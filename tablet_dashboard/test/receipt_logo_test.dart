import 'package:flutter_test/flutter_test.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/cart_line.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logo berubah jadi bitmap 1-bit yang bisa dicetak', () async {
    final logo = await ReceiptLogo.load();
    expect(logo, isNotNull, reason: 'asset ${ReceiptLogo.asset} harus kebaca');

    // Gambar 928x269 diskala ke lebar cetak 320 titik
    expect(logo!.width, ReceiptLogo.printWidth);
    expect(logo.bytesPerRow, 40);
    expect(logo.height, closeTo(269 * 320 / 928, 2));
    expect(logo.bits.length, logo.bytesPerRow * logo.height);

    final ink = logo.bits.fold(
      0,
      (sum, byte) => sum + byte.toRadixString(2).replaceAll('0', '').length,
    );
    expect(
      ink,
      greaterThan(logo.width * logo.height ~/ 20),
      reason: 'logo harus ada tintanya',
    );
  });

  test('struk cetak bitmap logo, bukan nama toko', () async {
    final logo = await ReceiptLogo.load();
    final receipt = Receipt(
      number: 'BK-1',
      createdAt: DateTime(2026, 9, 24, 14, 5),
      cashier: 'Wibawa Mukti',
      customer: 'Iqbal Apriand',
      capster: 'Wahyu',
      lines: const [
        CartLine(
          ServiceItem(id: 'SVC-1', name: 'Classic Hair Cut', price: 45000),
        ),
      ],
      method: PaymentType.cash,
      cash: 50000,
    );

    final withLogo = receipt.toEscPos(logo: logo);
    // GS v 0 tepat setelah reset ESC @ dan rata tengah
    expect(withLogo.sublist(5, 8), [0x1D, 0x76, 0x30]);
    expect(withLogo.length, greaterThan(receipt.toEscPos().length));
  });
}
