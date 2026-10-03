import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu layanan dengan harga dan "+ Tambah". Sudah di keranjang =
// tombol jadi "Dipilih", tap lagi untuk keluarkan dari keranjang
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ServiceItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _padding = EdgeInsets.fromLTRB(12, 14, 12, 12);
  static const _iconBox = 40.0;
  static final _nameStyle = AppTextStyle.bodyBold.copyWith(
    fontSize: 13,
    height: 1.3,
  );
  static final _priceStyle = AppTextStyle.bodyBold.copyWith(
    color: AppColor.gold,
  );

  // Tinggi 1 baris teks setelah ikut setelan ukuran font tablet
  static double _line(TextScaler scaler, TextStyle style) =>
      scaler.scale(style.fontSize!) * style.height!;

  static double _buttonHeight(TextScaler scaler) =>
      math.max(32, _line(scaler, AppTextStyle.label) + 12);

  // Lebar minimum kartu, ikut membesar kalau font tablet diperbesar
  static double minWidthFor(TextScaler scaler) => 160 * scaler.scale(14) / 14;

  // Tinggi kartu di grid: muat nama 2 baris, tipe, harga, dan tombol
  // tanpa ada teks yang kepotong, berapa pun ukuran font tablet
  static double heightFor(TextScaler scaler) =>
      _padding.vertical +
      2 + // border atas-bawah
      _iconBox +
      8 +
      _line(scaler, _nameStyle) * 2 +
      _line(scaler, AppTextStyle.caption) +
      6 + // jarak tipe ke harga
      _line(scaler, _priceStyle) +
      8 +
      _buttonHeight(scaler);

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);

    return AppCard(
      color: selected ? AppColor.goldSoft : null,
      padding: _padding,
      child: Column(
        children: [
          Container(
            width: _iconBox,
            height: _iconBox,
            decoration: const BoxDecoration(
              color: AppColor.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: AppIcon(ServiceIcon.of(item), size: 20, color: AppColor.ink),
          ),
          const SizedBox(height: 8),
          // Nama 1 baris menyisakan ruang di bawah tipe, jadi harga dan
          // tombol tetap sejajar dengan kartu lain di baris yang sama
          Expanded(
            child: Column(
              children: [
                Flexible(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: _nameStyle,
                  ),
                ),
                Text(
                  item.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(PriceFormat.full(item.price), style: _priceStyle),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: _buttonHeight(scaler),
            child: selected
                ? FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: EdgeInsets.zero,
                      textStyle: AppTextStyle.label,
                    ),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Dipilih'),
                  )
                : TextButton(
                    // Padding bawaan 8 atas-bawah bikin teks kepotong
                    style: AppButtonStyle.softGold.copyWith(
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    ),
                    onPressed: onTap,
                    child: const Text('+ Tambah', style: AppTextStyle.label),
                  ),
          ),
        ],
      ),
    );
  }
}
