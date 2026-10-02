import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_dialogs.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Status shift + tombol buka / tutup shift
class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final session = shift.session;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Status Operasional', style: AppTextStyle.title),
          const SizedBox(height: 12),
          Text(
            session == null
                ? 'Shift kasir belum dibuka'
                : 'Shift sedang berjalan',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          Text(
            session == null
                ? 'Buka shift untuk mulai transaksi'
                : 'Modal awal ${PriceFormat.full(session.openingBalance)}',
            style: AppTextStyle.bodyBold,
          ),
          const SizedBox(height: 16),
          if (session == null)
            FilledButton(
              onPressed: shift.busy ? null : () => showOpenShiftDialog(context),
              child: const Text('Buka Shift Kasir'),
            )
          else
            OutlinedButton(
              style: AppButtonStyle.dangerOutlined,
              onPressed: shift.busy
                  ? null
                  : () => showCloseShiftDialog(context),
              child: const Text('Tutup Shift Kasir'),
            ),
        ],
      ),
    );
  }
}
