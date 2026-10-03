import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/network_avatar.dart';

class BarberChip extends StatelessWidget {
  const BarberChip({super.key, required this.capster});

  final CapsterItem capster;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          NetworkAvatar(url: capster.imageUrl, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  capster.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(
                    fontSize: 12,
                    color: AppColor.surface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      AppAssets.starHistoryFilled,
                      width: 10,
                      height: 10,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      capster.avgRating.toStringAsFixed(1),
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColor.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris barber di daftar "Lihat Semua". Nama boleh dua baris, tidak
/// dipotong seperti di BarberChip yang lebarnya tetap.
class BarberTile extends StatelessWidget {
  const BarberTile({super.key, required this.capster});

  final CapsterItem capster;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: <Widget>[
          NetworkAvatar(url: capster.imageUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              capster.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            AppAssets.starHistoryFilled,
            width: 13,
            height: 13,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 4),
          Text(
            capster.avgRating.toStringAsFixed(1),
            style: AppTextStyle.titleSmall.copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
