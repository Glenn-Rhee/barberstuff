import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_summary_cards.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingConfirmStep extends StatelessWidget {
  const BookingConfirmStep({super.key});

  static const int appServiceFee = 2000;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final String locale = Localizations.localeOf(context).toLanguageTag();

    final DateTime? at = p.bookingDateTime;
    final String schedule = at == null
        ? '-'
        : formatBookingSchedule(at, locale);

    final double subTotal = p.subTotal;
    final double total = subTotal + appServiceFee;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: <Widget>[
        BookingDetailCard(
          rows: <BookingDetailRow>[
            BookingDetailRow(
              label: l10n.bookingConfirmBranch,
              value: p.store?.name ?? '-',
              iconPath: AppAssets.locationIcon,
            ),
            BookingDetailRow(
              label: l10n.bookingConfirmService,
              value: '-',
              iconPath: AppAssets.scissorsDashboard,
              items: <BookingPricedItem>[
                for (final ServiceItem s in p.selectedServices)
                  BookingPricedItem(name: s.name, price: s.price),
              ],
            ),
            BookingDetailRow(
              label: l10n.bookingConfirmBarber,
              value: p.capster?.name ?? '-',
              iconPath: AppAssets.userProfile,
            ),
            BookingDetailRow(
              label: l10n.bookingConfirmSchedule,
              value: schedule,
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
          subtotal: subTotal,
          fee: appServiceFee.toDouble(),
          total: total,
        ),
      ],
    );
  }
}
