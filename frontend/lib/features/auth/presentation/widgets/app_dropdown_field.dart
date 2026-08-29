import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_field_decoration.dart';

class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    super.key,
    required this.hint,
    required this.iconPath,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
  });

  final String hint;
  final String iconPath;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? Function(T?)? validator;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
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
    return DropdownButtonFormField<T>(
      focusNode: _focusNode,
      value: widget.value,
      validator: widget.validator,
      items: widget.items,
      onChanged: widget.onChanged,
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppField.radius),
      dropdownColor: AppColor.surface,
      style: AppTextStyle.bodyMedium,
      icon: const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColor.inkFaint),
      ),
      hint: Text(
        widget.hint,
        style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
      ),
      decoration: AppField.decoration(
        hint: widget.hint,
        iconPath: widget.iconPath,
        focused: _focused,
      ),
    );
  }
}
