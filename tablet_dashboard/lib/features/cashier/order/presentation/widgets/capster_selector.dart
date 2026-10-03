import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';

// Dropdown capster aktif untuk pesanan langsung
class CapsterSelector extends StatelessWidget {
  const CapsterSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.loading = false,
  });

  final Capster? value;
  final List<Capster> options;
  final ValueChanged<Capster> onChanged;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    return PopupMenuButton<Capster>(
      tooltip: 'Pilih capster',
      position: PopupMenuPosition.under,
      enabled: options.isNotEmpty,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final capster in options)
          PopupMenuItem(
            value: capster,
            child: Row(
              children: [
                PersonAvatar(
                  name: capster.name,
                  photo: capster.photoUrl,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(capster.name, style: AppTextStyle.body),
                if (capster.rating > 0) ...[
                  const SizedBox(width: 12),
                  const AppIcon(AppAsset.starIcon, size: 14, tint: false),
                  Text(
                    capster.rating.toStringAsFixed(1),
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          children: [
            if (value == null)
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColor.surfaceMuted,
                child: AppIcon(
                  AppAsset.scissorsIcon,
                  size: 16,
                  color: AppColor.inkFaint,
                ),
              )
            else
              PersonAvatar(name: value.name, photo: value.photoUrl),
            const SizedBox(width: 10),
            Expanded(
              child: value == null && loading && options.isEmpty
                  ? const Skeleton(child: SkeletonBox(width: 140))
                  : value == null
                  ? Text(
                      options.isEmpty
                          ? 'Capster belum tersedia'
                          : 'Pilih capster',
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value.name, style: AppTextStyle.bodyBold),
                        if (value.rating > 0)
                          Row(
                            children: [
                              const AppIcon(
                                AppAsset.starIcon,
                                size: 14,
                                tint: false,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                value.rating.toStringAsFixed(1),
                                style: AppTextStyle.caption,
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColor.inkSoft),
          ],
        ),
      ),
    );
  }
}
