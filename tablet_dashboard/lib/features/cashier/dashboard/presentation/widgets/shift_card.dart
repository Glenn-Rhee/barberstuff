import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_dialogs.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// "Status Operasional": shift yang berjalan + tombol buka / tutup shift
class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key});

  // Nama shift ikut jam sekarang
  static String shiftName(DateTime now) => switch (now.hour) {
    < 11 => 'Shift Pagi',
    < 15 => 'Shift Siang',
    < 18 => 'Shift Sore',
    _ => 'Shift Malam',
  };

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final hours = context.select<StoreController, String?>(
      (s) => s.current?.hours,
    );
    final session = shift.session;
    final name = shiftName(DateTime.now());

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Status Operasional', style: AppTextStyle.title),
          const SizedBox(height: 12),
          if (!shift.enabled) ...[
            Text(
              'Shift dan pembayaran hanya bisa dikelola akun kasir.',
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
            if (hours != null)
              Text('Jam toko $hours', style: AppTextStyle.bodyBold),
          ] else ...[
            Text(
              session == null
                  ? 'Shift kasir belum dibuka'
                  : 'Shift Sedang Berjalan:',
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
            Text(
              session == null
                  ? 'Buka shift untuk mulai transaksi'
                  : hours == null
                  ? name
                  : '$name ($hours)',
              style: AppTextStyle.bodyBold,
            ),
            if (session != null)
              Text(
                'Saldo awal ${PriceFormat.full(session.openingBalance)}',
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
            const SizedBox(height: 16),
            if (session == null)
              FilledButton(
                onPressed: shift.busy
                    ? null
                    : () => showOpenShiftDialog(context),
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
        ],
      ),
    );
  }
}
