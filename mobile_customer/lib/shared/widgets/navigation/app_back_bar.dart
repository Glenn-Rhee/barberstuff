import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// AppBar standar halaman dalam: latar putih, tombol kembali, judul tebal.
///
/// Dua gaya ikon kembali masih dipakai di aplikasi: panah custom
/// ([AppAssets.backArrowIcon]) dan [BackButton] bawaan Material
/// ([useMaterialBackIcon] = true).
class AppBackBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBackBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.useMaterialBackIcon = false,
  });

  final String title;

  /// Default-nya `Navigator.maybePop`.
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool useMaterialBackIcon;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.surface,
      elevation: 0,
      titleSpacing: 0,
      leading: useMaterialBackIcon
          ? BackButton(color: AppColor.ink, onPressed: onBack)
          : IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: Image.asset(
                AppAssets.backArrowIcon,
                width: 20,
                height: 16,
                fit: BoxFit.contain,
                color: AppColor.ink,
                filterQuality: FilterQuality.medium,
              ),
            ),
      title: Text(
        title,
        style: AppTextStyle.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      ),
      actions: actions,
    );
  }
}
