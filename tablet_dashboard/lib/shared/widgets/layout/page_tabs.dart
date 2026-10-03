import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Tab teks dengan garis emas di bawah ("Sesi Kasir", "History Harian")
class PageTabs extends StatelessWidget {
  const PageTabs({
    super.key,
    required this.tabs,
    required this.selected,
    this.icons,
    this.onChanged,
  });

  final List<String> tabs;
  final int selected;
  final List<IconData>? icons;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: [
          for (final (index, label) in tabs.indexed)
            InkWell(
              onTap: onChanged == null ? null : () => onChanged!(index),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == selected
                          ? AppColor.gold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (icons != null) ...[
                      Icon(
                        icons![index],
                        size: 16,
                        color: index == selected
                            ? AppColor.gold
                            : AppColor.inkSoft,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: index == selected
                            ? AppColor.gold
                            : AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
