import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Judul + subjudul halaman di kiri, [actions] di kanan
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
