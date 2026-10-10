import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Satu layanan di keranjang, tombol hapus kalau [onRemove] diisi.
// [onAdd] diisi = mode jumlah: hapus jadi -1, "x[qty]", lalu tombol +
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.subtitle,
    this.qty = 1,
    this.onAdd,
    this.onRemove,
  });

  final ServiceItem item;
  final String subtitle;
  final int qty;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;
    final onAdd = this.onAdd;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.borderStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcon(ServiceIcon.of(item), size: 16, color: AppColor.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyBold.copyWith(fontSize: 12),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormat.full(item.price * qty),
                style: AppTextStyle.label,
              ),
              if (onAdd != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RemoveButton(
                      tooltip: qty > 1 ? 'Kurangi 1' : 'Hapus',
                      onPressed: onRemove,
                      size: 26,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        'x$qty',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.label,
                      ),
                    ),
                    SizedBox.square(
                      dimension: 26,
                      child: IconButton(
                        tooltip: 'Tambah 1',
                        onPressed: onAdd,
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        color: AppColor.ink,
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(
                              color: AppColor.borderStrong,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ] else if (qty > 1)
                Text(
                  'x$qty @ ${PriceFormat.full(item.price)}',
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
            ],
          ),
          if (onAdd == null && onRemove != null) ...[
            const SizedBox(width: 8),
            _RemoveButton(tooltip: 'Hapus', onPressed: onRemove, size: 30),
          ],
        ],
      ),
    );
  }
}

// Tombol sampah merah, abu-abu kalau [onPressed] null
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    required this.tooltip,
    required this.onPressed,
    required this.size,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox.square(
      dimension: size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: enabled
                  ? AppColor.danger.withValues(alpha: 0.4)
                  : AppColor.borderStrong,
            ),
          ),
        ),
        icon: AppIcon(
          AppAsset.trashIcon,
          size: 14,
          color: enabled ? AppColor.danger : AppColor.inkSoft,
        ),
      ),
    );
  }
}
