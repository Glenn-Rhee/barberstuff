import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
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
        : '${DateFormat('EEEE, d MMM y', locale).format(at)} • '
              '${DateFormat('HH:mm', locale).format(at)}';

    final double subTotal = p.subTotal;
    final double total = subTotal + appServiceFee;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: <Widget>[
        _DetailCard(
          rows: <_DetailRow>[
            _DetailRow(
              label: l10n.bookingConfirmBranch,
              value: p.store?.name ?? '-',
              iconPath: AppAssets.locationIcon,
            ),
            _DetailRow(
              label: l10n.bookingConfirmService,
              value: p.selectedServices.isEmpty
                  ? '-'
                  : p.selectedServices
                        .map((ServiceItem s) => s.name)
                        .join(', '),
              iconPath: AppAssets.scissorsDashboard,
              trailing: p.selectedServices.isEmpty
                  ? null
                  : formatRupiah(subTotal),
            ),
            _DetailRow(
              label: l10n.bookingConfirmBarber,
              value: p.capster?.name ?? '-',
              iconPath: AppAssets.userProfile,
            ),
            _DetailRow(
              label: l10n.bookingConfirmSchedule,
              value: schedule,
              iconPath: AppAssets.birthDateIcon,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _PaymentCard(
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

class _DetailRow {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.iconPath,
    this.trailing,
  });

  final String label;
  final String value;
  final String iconPath;
  final String? trailing;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColor.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    rows[i].label,
                    style: AppTextStyle.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColor.inkFaint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        rows[i].iconPath,
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                        color: AppColor.goldDeep,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rows[i].value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                        ),
                      ),
                      if (rows[i].trailing != null) ...<Widget>[
                        const SizedBox(width: 10),
                        Text(
                          rows[i].trailing!,
                          style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.title,
    required this.subtotalLabel,
    required this.feeLabel,
    required this.totalLabel,
    required this.subtotal,
    required this.fee,
    required this.total,
  });

  final String title;
  final String subtotalLabel;
  final String feeLabel;
  final String totalLabel;
  final double subtotal;
  final double fee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyle.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          _Line(label: subtotalLabel, value: formatRupiah(subtotal)),
          const SizedBox(height: 8),
          _Line(label: feeLabel, value: formatRupiah(fee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColor.border),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  totalLabel,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                ),
              ),
              Text(
                formatRupiah(total),
                style: AppTextStyle.titleSmall.copyWith(
                  fontSize: 14,
                  color: AppColor.goldDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 12,
              color: AppColor.inkSoft,
            ),
          ),
        ),
        Text(value, style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
      ],
    );
  }
}
