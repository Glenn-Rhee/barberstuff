class PriceFormat {
  const PriceFormat._();

  // 150000 -> Rp 150.000
  static String full(int value) =>
      value < 0 ? '-Rp ${plain(-value)}' : 'Rp ${plain(value)}';

  // 100000 -> 100k, buat kartu yang sempit
  static String short(int value) {
    if (value >= 1000 && value % 1000 == 0) return '${value ~/ 1000}k';
    return plain(value);
  }

  // 150000 -> 150.000
  static String plain(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
