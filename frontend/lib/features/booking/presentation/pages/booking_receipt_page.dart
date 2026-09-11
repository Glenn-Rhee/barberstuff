import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/phone_formatter.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:provider/provider.dart';

class BookingReceiptPage extends StatelessWidget {
  const BookingReceiptPage({super.key, required this.result});

  final BookingResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();

    String customerName = '-';
    String customerPhone = '';
    try {
      final dynamic profile = context.read<ProfileProvider>().profile;
      if (profile != null) {
        customerName = profile.name as String;
        customerPhone = profile.phoneNumber as String;
      }
    } on ProviderNotFoundException {
      customerName = '-';
    }

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
                  Center(
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: result.qrCode,
                      width: double.infinity,
                      height: 74,
                      color: AppColor.ink,
                      drawText: false,
                      errorBuilder: (BuildContext _, String _) =>
                          const SizedBox(height: 74),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _Row(
                    label: l10n.receiptStore,
                    value: result.store.name,
                  ),
                  _Row(
                    label: l10n.receiptAddress,
                    value: result.store.address,
                  ),
                  _Row(label: l10n.receiptName, value: customerName),
                  _Row(
                    label: l10n.receiptPhone,
                    value: customerPhone.isEmpty
                        ? '-'
                        : PhoneFormatter.display(customerPhone),
                  ),
                  _Row(
                    label: l10n.receiptDate,
                    value: DateFormat(
                      'd MMMM y',
                      locale,
                    ).format(result.bookingDate),
                  ),
                  _Row(
                    label: l10n.receiptTime,
                    value:
                        '${DateFormat('HH:mm', locale).format(result.bookingDate)} WIB',
                  ),
                  _Row(
                    label: l10n.receiptSpecialist,
                    value: result.capster.name,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: DottedDivider(),
                  ),
                  for (final BookingServiceInfo item in result.services)
                    _Row(
                      label: item.name,
                      value: formatRupiah(item.price),
                    ),
                  if (result.appServiceFee > 0)
                    _Row(
                      label: l10n.bookingAppFee,
                      value: formatRupiah(result.appServiceFee),
                    ),
                  const SizedBox(height: 6),
                  _Row(
                    label: l10n.receiptTotal,
                    value: formatRupiah(result.grandTotal),
                    strong: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
  const _Row({
    required this.label,
    required this.value,
    this.strong = false,
  });

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
