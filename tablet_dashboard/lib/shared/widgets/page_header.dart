import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle, this.actions = const [], this.onBack});

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
            style: IconButton.styleFrom(side: const BorderSide(color: AppColor.borderStrong)),
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.pageTitle),
              Text(subtitle, style: AppTextStyle.body.copyWith(color: AppColor.inkSoft)),
            ],
          ),
        ),
        for (final (index, action) in actions.indexed) ...[if (index > 0) const SizedBox(width: 12), action],
      ],
    );
  }
}
