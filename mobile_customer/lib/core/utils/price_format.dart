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
String formatRupiah(num value) =>
    'Rp${_groupThousands(value.round().toString())}';

/// Poin member dengan titik ribuan, misalnya 12.500. Tanda minus dibuang.
String formatPoints(int value) => _groupThousands(value.abs().toString());

/// Sisipkan titik tiap tiga digit dari kanan: "1234567" → "1.234.567".
String _groupThousands(String digits) {
  final StringBuffer out = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }

  return out.toString();
}
