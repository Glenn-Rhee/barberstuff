import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

/// Tiga batang vertikal yang memanjang bergantian.
class BoxLoader extends StatefulWidget {
  const BoxLoader({super.key, this.size = 96});

  static const Duration cycle = Duration(milliseconds: 1100);
  static const int barCount = 3;

  final double size;

  @override
  State<BoxLoader> createState() => _BoxLoaderState();
}

class _BoxLoaderState extends State<BoxLoader>
    with SingleTickerProviderStateMixin {
  static const double _canvas = 48;
  static const double _barWidth = 7;
  static const double _gap = 7;
  static const double _minHeight = 7;
  static const double _maxHeight = 36;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BoxLoader.cycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Puncak bergeser sepertiga putaran tiap batang.
  double _waveAt(int index) {
    final double phase = (_controller.value - index / BoxLoader.barCount) % 1.0;
    return math.sin(phase * math.pi).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.size / _canvas;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < BoxLoader.barCount; i++) ...<Widget>[
                if (i > 0) SizedBox(width: _gap * scale),
                _Bar(
                  wave: _waveAt(i),
                  width: _barWidth * scale,
                  height:
                      lerpDouble(_minHeight, _maxHeight, _waveAt(i))! * scale,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.wave, required this.width, required this.height});

  final double wave;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.lerp(AppColor.cream, AppColor.orangeLight, wave),
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}
