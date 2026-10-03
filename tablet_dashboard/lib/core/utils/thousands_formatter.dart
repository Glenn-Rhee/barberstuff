import 'package:flutter/services.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';

// Input angka otomatis pakai titik ribuan, mis. 75000 -> 75.000
class ThousandsFormatter extends TextInputFormatter {
  const ThousandsFormatter();

  // "75.000" -> 75000
  static int parse(String text) =>
      int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = PriceFormat.plain(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
