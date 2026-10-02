import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';

// Input nominal rupiah: "Rp 75.000", nilai angkanya pakai ThousandsFormatter.parse
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    this.onChanged,
    this.autofocus = false,
    this.hint = '0',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: const [ThousandsFormatter()],
      style: AppTextStyle.bodyBold,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Text(
            'Rp',
            style: AppTextStyle.bodyBold.copyWith(color: AppColor.inkSoft),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      onChanged: onChanged,
    );
  }
}
