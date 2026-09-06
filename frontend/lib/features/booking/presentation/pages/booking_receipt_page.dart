import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/phone_formatter.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_receipt.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:provider/provider.dart';

class BookingReceiptArgs {
  const BookingReceiptArgs({required this.receipt});

  final BookingReceipt receipt;
}

class BookingReceiptPage extends StatelessWidget {
  const BookingReceiptPage({super.key, required this.args});

  final BookingReceiptArgs args;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingReceipt r = args.receipt;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final ReceiptCodeType codeType = context
        .select<BookingCatalog, ReceiptCodeType>(
          (BookingCatalog c) => c.codeType,
        );

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.receiptTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: <Widget>[
                  _CodeBlock(value: r.orderId, type: codeType),
                  const SizedBox(height: 24),
                  _Card(
                    children: <Widget>[
                      _Row(label: l10n.receiptStore, value: r.store.name),
                      _Row(label: l10n.receiptAddress, value: r.store.address),
                      _Row(label: l10n.receiptName, value: r.customerName),
                      _Row(
                        label: l10n.receiptPhone,
                        value: PhoneFormatter.display(r.customerPhone),
                      ),
                      _Row(
                        label: l10n.receiptDate,
                        value: DateFormat('d MMMM y', locale).format(r.date),
                      ),
                      _Row(
                        label: l10n.receiptTime,
                        value: '${_time(r.time)} WIB',
                      ),
                      _Row(
                        label: l10n.receiptSpecialist,
                        value: r.capster.name,
                        underline: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    children: <Widget>[
                      for (final BookingService s in r.services)
                        _Row(label: s.name, value: PriceFormat.full(s.price)),
                      _Row(
                        label: l10n.receiptTotal,
                        value: PriceFormat.full(r.total),
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: BoxButton(
                label: l10n.receiptDownload,
                onPressed: () => showComingSoonDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _time(TimeOfDay t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.value, required this.type});

  final String value;
  final ReceiptCodeType type;

  @override
  Widget build(BuildContext context) {
    final bool isQr = type == ReceiptCodeType.qr;

    return Center(
      child: SizedBox(
        width: isQr ? 180 : double.infinity,
        height: isQr ? 180 : 90,
        child: BarcodeWidget(
          data: value,
          barcode: isQr ? Barcode.qrCode() : Barcode.code128(),
          drawText: false,
          color: AppColor.ink,
          errorBuilder: (BuildContext _, String _) =>
              const ColoredBox(color: AppColor.border),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
    this.underline = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: bold
                  ? AppTextStyle.titleSmall
                  : AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (bold ? AppTextStyle.titleSmall : AppTextStyle.titleSmall)
                  .copyWith(
                    decoration: underline ? TextDecoration.underline : null,
                    decorationColor: AppColor.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
