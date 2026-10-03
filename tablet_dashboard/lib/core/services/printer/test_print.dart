import 'dart:typed_data';

import 'package:tablet_dashboard/core/services/printer/esc_pos.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';

// Halaman tes: cek lebar, tebal, rata, teks besar, dan logo sekaligus
Uint8List buildTestPrint({
  required String printerName,
  required DateTime now,
  RasterImage? logo,
}) {
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
