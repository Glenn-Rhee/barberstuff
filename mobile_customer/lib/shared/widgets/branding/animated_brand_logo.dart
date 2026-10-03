import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/constants/app_duration.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class AnimatedBrandLogo extends StatefulWidget {
  const AnimatedBrandLogo({
    super.key,
    this.width,
    this.tint,
    this.shimmerColor,
    this.delay = Duration.zero,
    this.duration = AppDuration.logoIntro,
    this.onIntroEnd,
  });

  final double? width;
  final Color? tint;
  final Color? shimmerColor;
  final Duration delay;
  final Duration duration;
  final VoidCallback? onIntroEnd;

  static double widthFor(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * 0.7).clamp(220.0, 330.0);
  }

  @override
  State<AnimatedBrandLogo> createState() => _AnimatedBrandLogoState();
}

class _AnimatedBrandLogoState extends State<AnimatedBrandLogo>
    with TickerProviderStateMixin {
  static const double _shimmerStart = -0.4;
  static const double _shimmerEnd = 1.4;
  static const double _shimmerBand = 0.16;

  late final AnimationController _intro;
  late final AnimationController _breathe;

  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _rise;
  late final Animation<double> _shimmer;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: widget.duration);
    _breathe = AnimationController(
      vsync: this,
      duration: AppDuration.logoBreathe,
    );

    _opacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _rise = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _shimmer = Tween<double>(begin: _shimmerStart, end: _shimmerEnd).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.42, 1, curve: Curves.easeInOutSine),
      ),
    );

    _pulse = Tween<double>(
      begin: 1,
      end: 1.022,
    ).animate(CurvedAnimation(parent: _breathe, curve: Curves.easeInOut));

    _play();
  }

  Future<void> _play() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
    }

    await _intro.forward();
    if (!mounted) return;

    widget.onIntroEnd?.call();
    _breathe.repeat(reverse: true);
  }

  @override
  void dispose() {
    _intro.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_intro, _breathe]),
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _rise.value),
            child: Transform.scale(
              scale: _scale.value * _pulse.value,
              child: _withShimmer(child!),
            ),
          ),
        );
      },
      child: _logo(context),
    );
  }

  Widget _logo(BuildContext context) {
    final Widget image = Image.asset(
      AppAssets.logo,
      width: widget.width ?? AnimatedBrandLogo.widthFor(context),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    final Color? tint = widget.tint;
    if (tint == null) return image;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: image,
    );
  }

  Widget _withShimmer(Widget child) {
    final double position = _shimmer.value;
    if (position <= _shimmerStart || position >= _shimmerEnd) return child;

    final Color color = widget.shimmerColor ?? AppColor.shimmer;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0),
        ],
        stops: <double>[
          (position - _shimmerBand).clamp(0.0, 1.0),
          position.clamp(0.0, 1.0),
          (position + _shimmerBand).clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: child,
    );
  }
}
