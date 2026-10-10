import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Kolom cari dengan ikon kaca pembesar, tinggi 44
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initialValue = '',
    this.fillColor = AppColor.surface,
  });

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        style: AppTextStyle.body,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: fillColor,
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: AppIcon(AppAsset.searchIcon, color: AppColor.inkSoft),
          ),
        ),
      ),
    );
  }
}
