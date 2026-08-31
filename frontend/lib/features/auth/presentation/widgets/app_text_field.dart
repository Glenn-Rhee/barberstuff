import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_field_decoration.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.iconPath,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  final String hint;
  final String iconPath;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: AppTextStyle.bodyMedium,
      cursorColor: AppColor.orange,
      decoration: AppField.decoration(
        hint: widget.hint,
        iconPath: widget.iconPath,
        focused: _focused,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}
