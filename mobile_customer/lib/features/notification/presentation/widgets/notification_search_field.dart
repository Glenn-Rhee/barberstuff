import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class NotificationSearchField extends StatelessWidget {
  const NotificationSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
      cursorColor: AppColor.goldDeep,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColor.border.withValues(alpha: 0.28),
        hintText: hint,
        hintStyle: AppTextStyle.bodySmall.copyWith(
          fontSize: 13,
          color: AppColor.inkFaint,
        ),
        contentPadding: const EdgeInsets.fromLTRB(0, 13, 14, 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
          child: Image.asset(
            AppAssets.searchBookingIcon,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.inkFaint,
            filterQuality: FilterQuality.medium,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: _border(AppColor.border),
        enabledBorder: _border(AppColor.border),
        focusedBorder: _border(AppColor.goldDeep),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }
}
