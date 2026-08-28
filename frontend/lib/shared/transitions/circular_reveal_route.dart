import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_duration.dart';

class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({
    required this.builder,
    this.origin = Alignment.center,
    super.settings,
  }) : super(
         transitionDuration: AppDuration.revealTransition,
         reverseTransitionDuration: AppDuration.revealTransition,
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) => builder(context),
       );

  final WidgetBuilder builder;
  final Alignment origin;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (BuildContext context, Widget? inner) => ClipPath(
        clipper: _CircularRevealClipper(fraction: curved.value, origin: origin),
        child: inner,
      ),
      child: child,
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  const _CircularRevealClipper({required this.fraction, required this.origin});

  final double fraction;
  final Alignment origin;

  @override
  Path getClip(Size size) {
    final Offset center = origin.alongSize(size);
    final double dx = math.max(center.dx, size.width - center.dx);
    final double dy = math.max(center.dy, size.height - center.dy);
    final double maxRadius = math.sqrt(dx * dx + dy * dy);

    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.origin != origin;
}
