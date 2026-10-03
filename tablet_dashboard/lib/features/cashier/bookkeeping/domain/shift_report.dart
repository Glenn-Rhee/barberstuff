import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tablet_dashboard/core/services/printer/esc_pos.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';

// Laporan pembukuan: ringkasan shift untuk printer 58mm dan PDF
class ShiftReport {
  const ShiftReport._();

  // "09:00 - 21:00", jam buka & tutup shift
  static String sessionHours(CashHistoryEntry e) {
    final closed = e.closedAt;
    return '${DateFormatId.time(e.openedAt)} - '
        '${closed == null ? '-' : DateFormatId.time(closed)}';
  }

  // "Sesuai (Selisih Rp 0)" / "Lebih Rp 5.000" / "Kurang Rp 5.000"
  static String statusText(CashHistoryEntry e) => e.difference == 0
      ? 'Sesuai (Selisih Rp 0)'
      : '${e.statusLabel} ${PriceFormat.full(e.difference.abs())}';

  // Ringkasan satu shift untuk printer thermal
  static Uint8List escPos(CashHistoryEntry e, {RasterImage? logo}) {
    final pos = EscPos();
    if (logo != null) {
      pos
        ..raster(logo)
        ..feed();
    } else {
      pos.text('BARBERSTUFF', align: PosAlign.center, bold: true, large: true);
    }
    pos
      ..text('RINGKASAN SHIFT', align: PosAlign.center, bold: true)
      ..paragraph(e.storeName ?? '-', align: PosAlign.center)
      ..divider()
      ..row('Tanggal', DateFormatId.compactDate(e.openedAt))
      ..row('Kasir', e.staffName ?? '-')
      ..row('Sesi', sessionHours(e))
      ..divider()
      ..row('Saldo awal', PriceFormat.full(e.openingBalance))
      ..row('Tunai', PriceFormat.full(e.incomeCash))
      ..row('Non tunai', PriceFormat.full(e.incomeCashless))
      ..row('Pengeluaran', PriceFormat.full(-e.outcome))
      ..divider()
      ..row('Seharusnya', PriceFormat.full(e.expectedCash), bold: true)
      ..row('Aktual', PriceFormat.full(e.actualCash))
      ..row('Selisih', PriceFormat.full(e.difference), bold: true)
      ..text(e.statusLabel.toUpperCase(), align: PosAlign.center, bold: true)
      ..text('Non tunai tidak dihitung di laci', align: PosAlign.center)
      ..feed(4);
    return pos.build();
  }

  // PDF satu shift
  static Future<Uint8List> dayPdf(CashHistoryEntry e) {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _title('Detail Pembukuan', e.storeName),
            pw.Text(DateFormatId.longDate(e.openedAt)),
            pw.SizedBox(height: 16),
            _rows([
              ('Kasir jaga', e.staffName ?? '-'),
              ('Waktu sesi', sessionHours(e)),
              ('Saldo awal', PriceFormat.full(e.openingBalance)),
              ('Pendapatan tunai', PriceFormat.full(e.incomeCash)),
              ('Pendapatan non tunai', PriceFormat.full(e.incomeCashless)),
              ('Pengeluaran', PriceFormat.full(-e.outcome)),
              ('Saldo tunai seharusnya', PriceFormat.full(e.expectedCash)),
              ('Input fisik aktual kasir', PriceFormat.full(e.actualCash)),
              ('Status selisih', statusText(e)),
            ]),
            pw.SizedBox(height: 12),
            pw.Text(
              'Non tunai masuk rekening, tidak dihitung di fisik laci.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  // PDF semua shift di satu bulan
  static Future<Uint8List> monthPdf(
    List<CashHistoryEntry> entries, {
    required DateTime month,
    String? storeName,
  }) {
    int sum(int Function(CashHistoryEntry) pick) =>
        entries.fold(0, (total, e) => total + pick(e));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          _title(
            'Laporan Pembukuan ${DateFormatId.monthYear(month)}',
            storeName,
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'Tanggal',
              'Kasir',
              'Saldo Awal',
              'Tunai',
              'Non Tunai',
              'Pengeluaran',
              'Selisih',
            ],
            data: [
              for (final e in entries)
                [
                  DateFormatId.compactDate(e.openedAt),
                  e.staffName ?? '-',
                  PriceFormat.plain(e.openingBalance),
                  PriceFormat.plain(e.incomeCash),
                  PriceFormat.plain(e.incomeCashless),
                  PriceFormat.plain(e.outcome),
                  PriceFormat.plain(e.difference),
                ],
            ],
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          _rows([
            ('Jumlah shift', '${entries.length}'),
            (
              'Total pendapatan tunai',
              PriceFormat.full(sum((e) => e.incomeCash)),
            ),
            (
              'Total pendapatan non tunai',
              PriceFormat.full(sum((e) => e.incomeCashless)),
            ),
            ('Total pengeluaran', PriceFormat.full(sum((e) => e.outcome))),
            ('Total selisih', PriceFormat.full(sum((e) => e.difference))),
          ]),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _title(String title, String? store) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'BARBERSTUFF',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
      if (store != null) pw.Text(store),
    ],
  );

  static pw.Widget _rows(List<(String, String)> rows) => pw.Column(
    children: [
      for (final (label, value) in rows)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text(label), pw.Text(value)],
          ),
        ),
    ],
  );
}
