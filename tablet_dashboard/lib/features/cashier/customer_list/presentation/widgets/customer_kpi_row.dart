import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tiga angka di atas daftar pelanggan
class CustomerKpiRow extends StatelessWidget {
  const CustomerKpiRow({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CustomerHistoryController>();
    final members = PriceFormat.plain(history.memberCount);
    final loading = history.loading;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'TOTAL PELANGGAN',
            value: PriceFormat.plain(history.kpi.total),
            loading: loading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'MEMBER (PAKAI APLIKASI)',
            value: history.truncated ? '$members+' : members,
            loading: loading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'BARU BULAN INI',
            value: PriceFormat.plain(history.kpi.newThisMonth),
            loading: loading,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.loading,
  });

  final String label;
  final String value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const AppIcon(
              AppAsset.personIcon,
              size: 18,
              color: AppColor.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.label.copyWith(
                    fontSize: 10,
                    color: AppColor.inkSoft,
                  ),
                ),
                if (loading)
                  const Skeleton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SkeletonBox(width: 64, height: 20),
                    ),
                  )
                else
                  Text(value, style: AppTextStyle.h2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
