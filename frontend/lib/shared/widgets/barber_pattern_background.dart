import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class BarberPatternBackground extends StatelessWidget {
  const BarberPatternBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.patternColor,
    this.patternIntensity = 1,
    this.patternScale = 1.3,
    this.coverage = 1,
    this.fadeSpan = 0,
    this.progress = 1,
    this.riseOffset = 64,
  });

  /// Preset halaman auth: pola bawah yang sama dengan splash, tanpa animasi.
  const BarberPatternBackground.auth({super.key, required this.child})
    : backgroundColor = AppColor.surface,
      patternColor = null,
      patternIntensity = 1.2,
      patternScale = 1.25,
      coverage = 0.56,
      fadeSpan = 0.45,
      progress = 1,
      riseOffset = 0;

  final Widget child;
  final Color backgroundColor;
  final Color? patternColor;
  final double patternIntensity;
  final double patternScale;
  final double coverage;
  final double fadeSpan;
  final double progress;
  final double riseOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: backgroundColor),
        IgnorePointer(child: _pattern()),
        child,
      ],
    );
  }

  Widget _pattern() {
    final double value = progress.clamp(0.0, 1.0);
    if (value == 0 || patternIntensity == 0) return const SizedBox.shrink();

    Widget tile = DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(AppAssets.patternTile),
          repeat: ImageRepeat.repeat,
          scale: patternScale,
          filterQuality: FilterQuality.medium,
          colorFilter: _colorFilter(),
        ),
      ),
      child: const SizedBox.expand(),
    );

    if (fadeSpan > 0) {
      tile = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const <Color>[Color(0x00FFFFFF), Color(0xFFFFFFFF)],
          stops: <double>[0, fadeSpan.clamp(0.01, 1.0)],
        ).createShader(bounds),
        child: tile,
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: coverage.clamp(0.01, 1.0),
        child: Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * riseOffset),
            child: tile,
          ),
        ),
      ),
    );
  }

  ColorFilter? _colorFilter() {
    final Color? tint = patternColor;
    if (tint == null && patternIntensity == 1) return null;

    final double red = tint == null ? 1 : 0;
    final double green = tint == null ? 1 : 0;
    final double blue = tint == null ? 1 : 0;

    return ColorFilter.matrix(<double>[
      red,
      0,
      0,
      0,
      tint == null ? 0 : tint.r * 255,
      0,
      green,
      0,
      0,
      tint == null ? 0 : tint.g * 255,
      0,
      0,
      blue,
      0,
      tint == null ? 0 : tint.b * 255,
      0,
      0,
      0,
      patternIntensity,
      0,
    ]);
  }
}
