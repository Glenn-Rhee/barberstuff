import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Empat angka shift hari ini, strip (—) sampai shift dibuka
class TodayStatsRow extends StatelessWidget {
  const TodayStatsRow({super.key, required this.session});

  final CashSession? session;

  @override
  Widget build(BuildContext context) {
    final session = this.session;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_basket_outlined,
            color: AppColor.gold,
            title: 'Transaksi Hari Ini',
            value: session == null ? '—' : '${session.sales.length}',
            caption: session == null
                ? 'Shift belum dibuka'
                : '${session.cashSales} tunai · ${session.cashlessSales} non-tunai',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.show_chart,
            color: AppColor.success,
            title: 'Penjualan Hari Ini',
            value: session == null ? '—' : PriceFormat.full(session.income),
            caption: session == null
                ? 'Shift belum dibuka'
                : 'Tunai ${PriceFormat.plain(session.incomeCash)} · Non tunai ${PriceFormat.plain(session.incomeCashless)}',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_down,
            color: AppColor.danger,
            title: 'Kas Keluar',
            value: session == null ? '—' : PriceFormat.full(session.outcome),
            caption: session == null
                ? 'Shift belum dibuka'
                : 'Modal awal ${PriceFormat.plain(session.openingBalance)}',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_outlined,
            color: AppColor.info,
            title: 'Kas di Laci',
            value: session == null
                ? '—'
                : PriceFormat.full(session.expectedCash),
            caption: session == null
                ? 'Shift belum dibuka'
                : 'Perhitungan sistem',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyle.caption.copyWith(color: AppColor.inkSoft);

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppTextStyle.h1),
                ),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
