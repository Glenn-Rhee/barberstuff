import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 13});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Image.asset(
              star <= rating
                  ? AppAssets.starHistoryFilled
                  : AppAssets.starHistoryEmpty,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
      ],
    );
  }
}

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({super.key, required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _fallback()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => ColoredBox(
    color: AppColor.border,
    child: Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: AppColor.surface,
    ),
  );
}

class StoreActionButton extends StatelessWidget {
  const StoreActionButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: AppColor.surface,
          clipBehavior: Clip.antiAlias,
          shape: const CircleBorder(
            side: BorderSide(color: AppColor.goldDeep),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 19,
                  height: 19,
                  fit: BoxFit.contain,
                  color: AppColor.goldDeep,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

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
                        color: AppColor.goldSoft,
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

class StoreTabChip extends StatelessWidget {
  const StoreTabChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColor.goldDeep : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColor.goldDeep),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColor.surface : AppColor.goldDeep,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final String? label = actionLabel;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 15),
          ),
        ),
        if (trailing != null) trailing!,
        if (label != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              label,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 12,
                color: AppColor.goldDeep,
              ),
            ),
          ),
      ],
    );
  }
}
