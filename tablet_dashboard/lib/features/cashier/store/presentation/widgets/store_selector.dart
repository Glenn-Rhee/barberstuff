import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/domain/entities/store_info.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';

// Lokasi toko di header, admin bisa ganti cabang
class StoreSelector extends StatelessWidget {
  const StoreSelector({super.key});

  // Ganti cabang lalu muat ulang data yang ikut toko
  static void _switch(BuildContext context, StoreInfo store) {
    context.read<StoreController>().select(store);
    context.read<CatalogController>().load(store.id);
    context.read<AttendanceController>().load(store.id);
    context.read<DashboardController>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<StoreController>();
    final current = stores.current;
    final label = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppAsset.locationIcon, size: 18, color: AppColor.ink),
          const SizedBox(width: 6),
          if (stores.loading && current == null)
            const Skeleton(child: SkeletonBox(width: 120))
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                current?.displayName ?? 'Pilih cabang',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.label,
              ),
            ),
          const SizedBox(width: 6),
          if (stores.canSwitch)
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColor.inkSoft,
            )
          else
            const AppIcon(AppAsset.lockIcon, size: 14, color: AppColor.inkSoft),
        ],
      ),
    );

    if (!stores.canSwitch) {
      return Tooltip(
        message: 'Lokasi mengikuti akun, tidak bisa diganti',
        child: label,
      );
    }

    return PopupMenuButton<StoreInfo>(
      tooltip: 'Ganti cabang',
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      enabled: stores.options.isNotEmpty,
      onSelected: (store) => _switch(context, store),
      itemBuilder: (_) => [
        for (final store in stores.options)
          PopupMenuItem(
            value: store,
            child: Row(
              children: [
                Icon(
                  store.id == current?.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: AppColor.gold,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    store.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: label,
    );
  }
}

// "● Toko Buka" / "● Toko Tutup" sesuai status dan jam operasional.
// Pakai jam server, jam tablet bisa salah
class StoreOpenChip extends StatelessWidget {
  const StoreOpenChip({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.select<StoreController, StoreInfo?>((s) => s.current);
    final now = context.watch<ServerClock>().now();
    final open = store?.isOpenAt(now) ?? false;
    final color = open ? AppColor.success : AppColor.danger;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: open ? AppColor.successSoft : AppColor.dangerSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            open ? 'Toko Buka' : 'Toko Tutup',
            style: AppTextStyle.label.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
