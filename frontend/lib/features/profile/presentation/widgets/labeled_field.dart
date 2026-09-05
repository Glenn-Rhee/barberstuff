import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.iconPath,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.helper,
  });

  final String label;
  final String iconPath;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final String? helperText = helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyle.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyle.bodyMedium.copyWith(
            color: enabled ? AppColor.ink : AppColor.inkSoft,
          ),
          cursorColor: AppColor.orange,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColor.surface : AppColor.cream,
            isDense: true,
            contentPadding: const EdgeInsets.only(
              right: 16,
              top: 17,
              bottom: 17,
            ),
            prefixIcon: _Prefix(iconPath: iconPath, enabled: enabled),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: _border(AppColor.border, 1),
            enabledBorder: _border(AppColor.border, 1),
            disabledBorder: _border(AppColor.border, 1),
            focusedBorder: _border(AppColor.orangeLight, 1.5),
            errorBorder: _border(AppColor.danger, 1),
            focusedErrorBorder: _border(AppColor.danger, 1.5),
            errorStyle: AppTextStyle.bodySmall.copyWith(color: AppColor.danger),
          ),
        ),
        if (helperText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
          ),
        ],
      ],
    );
  }

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _Prefix extends StatelessWidget {
  const _Prefix({required this.iconPath, required this.enabled});

  final String iconPath;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: enabled ? AppColor.inkSoft : AppColor.inkFaint,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Container(width: 1, height: 26, color: AppColor.border),
        const SizedBox(width: 12),
      ],
    );
  }
}
