import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_duration.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

enum BoxButtonVariant { filled, outlined }

class BoxButton extends StatefulWidget {
  const BoxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconPath,
    this.variant = BoxButtonVariant.filled,
  });

  static const double minHeight = 52;

  final String label;
  final VoidCallback onPressed;
  final String? iconPath;
  final BoxButtonVariant variant;

  @override
  State<BoxButton> createState() => _BoxButtonState();
}

class _BoxButtonState extends State<BoxButton> {
  bool _pressed = false;

  bool get _isFilled => widget.variant == BoxButtonVariant.filled;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double radius = _isFilled ? BoxButton.minHeight / 2 : 12;
    final Color background = _isFilled
        ? AppColor.orangeLight
        : AppColor.surface;
    final Color foreground = _isFilled ? AppColor.surface : AppColor.ink;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: AppDuration.pressFeedback,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: AppDuration.pressFeedback,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: _isFilled
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColor.orangeLight.withValues(
                      alpha: _pressed ? 0.16 : 0.30,
                    ),
                    blurRadius: _pressed ? 8 : 16,
                    offset: Offset(0, _pressed ? 2 : 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: background,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: _isFilled
                ? BorderSide.none
                : const BorderSide(color: AppColor.border),
          ),
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (TapDownDetails _) => _setPressed(true),
            onTapUp: (TapUpDetails _) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            highlightColor: Colors.transparent,
            splashColor: _isFilled
                ? AppColor.surface.withValues(alpha: 0.18)
                : AppColor.orangeLight.withValues(alpha: 0.12),
            child: Container(
              constraints: const BoxConstraints(minHeight: BoxButton.minHeight),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.iconPath != null) ...<Widget>[
                    Image.asset(widget.iconPath!, width: 22, height: 22),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        softWrap: false,
                        style: AppTextStyle.labelLarge.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
