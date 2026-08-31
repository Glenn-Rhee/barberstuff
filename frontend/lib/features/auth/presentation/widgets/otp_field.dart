import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.hasError = false,
    this.enabled = true,
    this.onCompleted,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final bool enabled;
  final VoidCallback? onCompleted;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  int get _length => widget.controllers.length;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController c in widget.controllers) {
      c.addListener(_refresh);
    }
    for (final FocusNode f in widget.focusNodes) {
      f.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in widget.controllers) {
      c.removeListener(_refresh);
    }
    for (final FocusNode f in widget.focusNodes) {
      f.removeListener(_refresh);
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _distribute(String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < _length; i++) {
      widget.controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final int next = digits.length >= _length ? _length - 1 : digits.length;
    widget.focusNodes[next].requestFocus();
    _notifyIfCompleted();
  }

  void _notifyIfCompleted() {
    final bool filled = widget.controllers.every(
      (TextEditingController c) => c.text.isNotEmpty,
    );
    if (filled) widget.onCompleted?.call();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _distribute(value);
      return;
    }
    if (value.isNotEmpty && index < _length - 1) {
      widget.focusNodes[index + 1].requestFocus();
    }
    _notifyIfCompleted();
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    final bool isBackspace =
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace;

    if (isBackspace && widget.controllers[index].text.isEmpty && index > 0) {
      widget.controllers[index - 1].clear();
      widget.focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Color _borderColor(int index) {
    if (widget.hasError) return AppColor.danger;
    if (widget.focusNodes[index].hasFocus) return AppColor.orangeLight;
    if (widget.controllers[index].text.isNotEmpty) return AppColor.orangeLight;
    return AppColor.orangeLight.withValues(alpha: 0.4);
  }

  Widget _box(int index) {
    final bool focused = widget.focusNodes[index].hasFocus;

    return Focus(
      onKeyEvent: (FocusNode _, KeyEvent event) => _onKey(index, event),
      child: AspectRatio(
        aspectRatio: 1,
        child: TextField(
          controller: widget.controllers[index],
          focusNode: widget.focusNodes[index],
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textInputAction: index == _length - 1
              ? TextInputAction.done
              : TextInputAction.next,
          style: AppTextStyle.headlineSmall,
          cursorColor: AppColor.orange,
          showCursor: false,
          onChanged: (String value) => _onChanged(index, value),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: focused ? AppColor.cream : AppColor.surface,
            border: _border(index),
            enabledBorder: _border(index),
            focusedBorder: _border(index),
            disabledBorder: _border(index),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(int index) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: _borderColor(index),
      width: widget.focusNodes[index].hasFocus ? 1.5 : 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < _length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _box(i)),
        ],
      ],
    );
  }
}
