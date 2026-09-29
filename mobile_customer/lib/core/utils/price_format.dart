import 'package:intl/intl.dart';

class PriceFormat {
  const PriceFormat._();

  static String short(int value) {
    if (value >= 1000 && value % 1000 == 0) return 'Rp${value ~/ 1000}k';
    return full(value);
  }

  static String full(int value) =>
      'Rp ${NumberFormat.decimalPattern('id').format(value)},-';
}

/// Rupiah tanpa spasi dan tanpa ",-", misalnya Rp120.000.
String formatRupiah(num value) {
  final String digits = value.round().toString();
  final StringBuffer out = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }

  return 'Rp$out';
}
