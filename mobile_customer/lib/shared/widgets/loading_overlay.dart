import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isVisible,
    required this.child,
  });

  static const Duration fadeOut = Duration(milliseconds: 250);

  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: LoadingOverlay.fadeOut,
              curve: Curves.easeOut,
              child: Material(
                color: AppColor.backdrop.withValues(alpha: 0.72),
                child: Center(
                  child: TickerMode(
                    enabled: isVisible,
                    child: const BoxLoader(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
