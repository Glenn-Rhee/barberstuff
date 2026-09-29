import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_summary_cards.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

/// Rincian satu booking dari riwayat, tampil sama dengan langkah konfirmasi.
class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.record});

  final BookingRecord record;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();

    // Bukti pesanan berisi barcode untuk kasir; tidak berguna lagi kalau
    // booking-nya sudah dibatalkan.
    final bool canceled =
        record.statusAt(DateTime.now()) == BookingStatus.canceled;
    final double subtotal = record.lines.fold(
      0,
      (double sum, BookingLine line) => sum + line.price,
    );

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
          l10n.bookingDetailTitle,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: <Widget>[
                  BookingDetailCard(
                    rows: <BookingDetailRow>[
                      BookingDetailRow(
                        label: l10n.bookingConfirmBranch,
                        value: record.storeName,
                        iconPath: AppAssets.locationIcon,
                      ),
                      BookingDetailRow(
                        label: l10n.bookingConfirmService,
                        value: '-',
                        iconPath: AppAssets.scissorsDashboard,
                        items: <BookingPricedItem>[
                          for (final BookingLine line in record.lines)
                            BookingPricedItem(
                              name: line.name,
                              price: line.price,
                            ),
                        ],
                      ),
                      BookingDetailRow(
                        label: l10n.bookingConfirmBarber,
                        value: record.capsterName,
                        iconPath: AppAssets.userProfile,
                      ),
                      BookingDetailRow(
                        label: l10n.bookingConfirmSchedule,
                        value: formatBookingSchedule(
                          record.scheduledAt,
                          locale,
                        ),
                        iconPath: AppAssets.birthDateIcon,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BookingPaymentCard(
                    title: l10n.bookingPaymentTitle,
                    subtotalLabel: l10n.bookingSubtotal,
                    feeLabel: l10n.bookingAppFee,
                    totalLabel: l10n.bookingTotal,
                    subtotal: subtotal,
                    // 0 berarti tidak diketahui: daftar dari server tidak
                    // mengirim biaya layanan.
                    fee: record.appServiceFee > 0
                        ? record.appServiceFee.toDouble()
                        : null,
                    total: record.totalPrice,
                  ),
                ],
              ),
            ),
            if (!canceled)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: BoxButton(
                  label: l10n.bookingSuccessReceipt,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoute.bookingReceipt, arguments: record),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
