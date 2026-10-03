import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Tombol "← Kembali" di atas judul halaman turunan
class BackTextButton extends StatelessWidget {
  const BackTextButton({super.key, this.onPressed});

  // Kosong = tutup halaman ini
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.ink,
        backgroundColor: AppColor.surface,
        side: const BorderSide(color: AppColor.borderStrong),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: const AppIcon(AppAsset.backArrowIcon, size: 18),
      label: const Text('Kembali'),
    );
  }
}
