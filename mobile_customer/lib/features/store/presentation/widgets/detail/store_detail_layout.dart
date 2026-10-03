import 'package:flutter/widgets.dart';

/// Ukuran bersama halaman detail cabang.
class StoreDetailLayout {
  const StoreDetailLayout._();

  static const double sidePadding = 20;

  /// Skala teks untuk baris horizontal (barber, tab) supaya tingginya ikut
  /// membesar saat ukuran huruf HP dinaikkan, tapi tidak tanpa batas.
  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);
}
