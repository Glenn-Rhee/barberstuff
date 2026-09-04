import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class BoxLoader extends StatefulWidget {
  const BoxLoader({super.key, this.size = 96});

  static const Duration cycle = Duration(milliseconds: 1600);

  final double size;

  @override
  State<BoxLoader> createState() => _BoxLoaderState();
}

class _BoxLoaderState extends State<BoxLoader>
    with SingleTickerProviderStateMixin {
  static const double _canvas = 48;
  static const double _cell = 20;
  static const double _radius = 3;

  static const List<Offset> _corners = <Offset>[
    Offset(4, 4),
    Offset(24, 4),
    Offset(24, 24),
    Offset(4, 24),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BoxLoader.cycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Rect _cellAt(int index) => _corners[index % 4] & const Size(_cell, _cell);

  Widget _box(Rect at, Color color, double k) {
    return Positioned(
      left: at.left * k,
      top: at.top * k,
      width: at.width * k,
      height: at.height * k,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius * k),
        child: Image.asset(
          AppAssets.topBox,
          color: color,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double k = widget.size / _canvas;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = _controller.value * 4;
          final int step = t.floor().clamp(0, 3);
          final double progress = Curves.easeInOut.transform(
            (t - step).clamp(0.0, 1.0),
          );

          final Rect head = Rect.lerp(
            _cellAt(step),
            _cellAt(step + 1),
            progress,
          )!;

          return Stack(
            children: <Widget>[
              for (int i = 0; i < step; i++)
                _box(
                  _cellAt(i).expandToInclude(_cellAt(i + 1)),
                  AppColor.cream,
                  k,
                ),
              _box(_cellAt(step).expandToInclude(head), AppColor.cream, k),
              _box(head, AppColor.orangeLight, k),
            ],
          );
        },
      ),
    );
  }
}
