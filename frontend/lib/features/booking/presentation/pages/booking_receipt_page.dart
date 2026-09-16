import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/phone_formatter.dart';
import 'package:mobile_barberstuff/features/booking/data/receipt_pdf.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class BookingReceiptPage extends StatefulWidget {
  const BookingReceiptPage({super.key, required this.record});

  final BookingRecord record;

  @override
  State<BookingReceiptPage> createState() => _BookingReceiptPageState();
}

class _BookingReceiptPageState extends State<BookingReceiptPage> {
  bool _exporting = false;

  ({String name, String phone}) _customer() {
    try {
      final dynamic profile = context.read<ProfileProvider>().profile;
      if (profile == null) return (name: '-', phone: '');
      return (
        name: profile.name as String,
        phone: profile.phoneNumber as String,
      );
    } on ProviderNotFoundException {
      return (name: '-', phone: '');
    }
  }

  Future<void> _download() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final ({String name, String phone}) customer = _customer();

    try {
      final List<int> bytes = await buildReceiptPdf(
        record: widget.record,
        locale: locale,
        customerName: customer.name,
        customerPhone: customer.phone.isEmpty
            ? ''
            : PhoneFormatter.display(customer.phone),
        labels: ReceiptLabels(
          title: l10n.receiptTitle,
          store: l10n.receiptStore,
          address: l10n.receiptAddress,
          name: l10n.receiptName,
          phone: l10n.receiptPhone,
          date: l10n.receiptDate,
          time: l10n.receiptTime,
          specialist: l10n.receiptSpecialist,
          appFee: l10n.bookingAppFee,
          total: l10n.receiptTotal,
        ),
      );

      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'e-receipt-${widget.record.id}.pdf',
      );
    } on Object catch (_) {
      if (mounted) AppToast.show(context, message: l10n.exceptionDefault);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final BookingRecord record = widget.record;
    final ({String name, String phone}) customer = _customer();

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Image.asset(
            AppAssets.backArrowIcon,
            width: 20,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.ink,
            filterQuality: FilterQuality.medium,
          ),
        ),
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
                  if (record.qrCode.isNotEmpty)
                    Center(
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: record.qrCode,
                        width: double.infinity,
                        height: 74,
                        color: AppColor.ink,
                        drawText: false,
                        errorBuilder: (BuildContext _, String _) =>
                            const SizedBox(height: 74),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _ReceiptCard(
                    children: <Widget>[
                      _Row(label: l10n.receiptStore, value: record.storeName),
                      _Row(
                        label: l10n.receiptAddress,
                        value: record.storeAddress,
                      ),
                      _Row(label: l10n.receiptName, value: customer.name),
                      _Row(
                        label: l10n.receiptPhone,
                        value: customer.phone.isEmpty
                            ? '-'
                            : PhoneFormatter.display(customer.phone),
                      ),
                      _Row(
                        label: l10n.receiptDate,
                        value: DateFormat(
                          'd MMMM y',
                          locale,
                        ).format(record.scheduledAt),
                      ),
                      _Row(
                        label: l10n.receiptTime,
                        value:
                            '${DateFormat('HH:mm', locale).format(record.scheduledAt)} WIB',
                      ),
                      _Row(
                        label: l10n.receiptSpecialist,
                        value: record.capsterName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ReceiptCard(
                    children: <Widget>[
                      for (final BookingLine line in record.lines)
                        _Row(label: line.name, value: formatRupiah(line.price)),
                      if (record.appServiceFee > 0)
                        _Row(
                          label: l10n.bookingAppFee,
                          value: formatRupiah(record.appServiceFee),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: DottedDivider(),
                      ),
                      _Row(
                        label: l10n.receiptTotal,
                        value: formatRupiah(record.grandTotal),
                        strong: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: BoxButton(
                label: l10n.receiptDownload,
                isLoading: _exporting,
                onPressed: _exporting ? null : _download,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = (constraints.maxWidth / 6).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (int _) => Container(width: 3, height: 1, color: AppColor.border),
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: strong
                  ? AppTextStyle.titleSmall.copyWith(fontSize: 13)
                  : AppTextStyle.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColor.inkSoft,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
