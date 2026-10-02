import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Kolom cari dengan ikon kaca pembesar, tinggi 44
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initialValue = '',
  });

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

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
          fillColor: AppColor.surface,
          prefixIcon: const Icon(Icons.search, color: AppColor.inkSoft),
        ),
      ),
    );
  }
}
