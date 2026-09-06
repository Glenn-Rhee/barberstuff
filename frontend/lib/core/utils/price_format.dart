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
