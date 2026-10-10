import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

<<<<<<< HEAD
// Judul + subjudul halaman di kiri, [actions] di kanan.
// [onBack] diisi = muncul tombol kembali
=======
// Judul + subjudul di kiri, [actions] di kanan, [onBack] = tombol kembali
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.onBack,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          IconButton.outlined(
            onPressed: onBack,
            tooltip: 'Kembali',
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColor.borderStrong),
            ),
            icon: const AppIcon(AppAsset.backArrowIcon, size: 18),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.h1),
              Text(
                subtitle,
                style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
              ),
            ],
          ),
        ),
        for (final (index, action) in actions.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          action,
        ],
      ],
    );
  }
}
