import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptLabels {
  const ReceiptLabels({
    required this.title,
    required this.store,
    required this.address,
    required this.name,
    required this.phone,
    required this.date,
    required this.time,
    required this.specialist,
    required this.appFee,
    required this.total,
  });

  final String title;
  final String store;
  final String address;
  final String name;
  final String phone;
  final String date;
  final String time;
  final String specialist;
  final String appFee;
  final String total;
}

/// Struk siap simpan/bagikan. Dipakai tombol "Download E-Receipt".
Future<List<int>> buildReceiptPdf({
  required BookingRecord record,
  required ReceiptLabels labels,
  required String customerName,
  required String customerPhone,
  required String locale,
}) async {
  final pw.Document doc = pw.Document();
  final DateFormat dateFormat = DateFormat('d MMMM y', locale);
  final DateFormat timeFormat = DateFormat('HH:mm', locale);

  pw.Widget row(String label, String value, {bool strong = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: strong ? PdfColors.black : PdfColors.grey700,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget card(List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            labels.title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          if (record.qrCode.isNotEmpty)
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: record.qrCode,
                width: 220,
                height: 56,
                drawText: false,
              ),
            ),
          pw.SizedBox(height: 18),
          card(<pw.Widget>[
            row(labels.store, record.storeName),
            row(labels.address, record.storeAddress),
            row(labels.name, customerName),
            row(labels.phone, customerPhone.isEmpty ? '-' : customerPhone),
            row(labels.date, dateFormat.format(record.scheduledAt)),
            row(labels.time, '${timeFormat.format(record.scheduledAt)} WIB'),
            row(labels.specialist, record.capsterName),
          ]),
          pw.SizedBox(height: 12),
          card(<pw.Widget>[
            for (final BookingLine line in record.lines)
              row(line.name, formatRupiah(line.price)),
            if (record.appServiceFee > 0)
              row(labels.appFee, formatRupiah(record.appServiceFee)),
            pw.Divider(color: PdfColors.grey300),
            row(labels.total, formatRupiah(record.totalPrice), strong: true),
          ]),
        ],
      ),
    ),
  );

  return doc.save();
}
