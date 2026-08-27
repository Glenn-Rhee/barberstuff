import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/animated_brand_logo.dart';
import '../../../../shared/widgets/barber_pattern_background.dart';
import '../../../../src/core/constants/app_duration.dart';
import '../../../../theme/app_color.dart';
import '../widgets/brand_glow.dart';

class SplashBrandPage extends StatefulWidget {
  const SplashBrandPage({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<SplashBrandPage> createState() => _SplashBrandPageState();
}

class _SplashBrandPageState extends State<SplashBrandPage>
    with TickerProviderStateMixin {
  late final AnimationController _backdrop;
  late final AnimationController _glow;

  late final Animation<double> _backdropReveal;
  late final Animation<double> _glowScale;

  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    _backdrop = AnimationController(
      vsync: this,
      duration: AppDuration.backdropIntro,
    );

    _glow = AnimationController(
      vsync: this,
      duration: AppDuration.logoBreathe,
    );

    _backdropReveal = CurvedAnimation(
      parent: _backdrop,
      curve: Curves.easeOut,
    );

    _glowScale = Tween<double>(begin: 0.9, end: 1.35).animate(
      CurvedAnimation(parent: _glow, curve: Curves.easeInOut),
    );

    _backdrop.forward();
    _glow.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backdrop.dispose();
    _glow.dispose();
    super.dispose();
  }

  Future<void> _handleIntroEnd() async {
    if (_isFinished) return;
    _isFinished = true;

    await Future<void>.delayed(AppDuration.brandHold);
    if (!mounted) return;

    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColor.orangeLight,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColor.orangeLight,
        body: AnimatedBuilder(
          animation: _backdropReveal,
          builder: (BuildContext context, Widget? child) =>
              BarberPatternBackground(
                backgroundColor: AppColor.orangeLight,
                patternColor: AppColor.surface,
                patternIntensity: 1.5,
                patternScale: 1.25,
                coverage: 0.56,
                fadeSpan: 0.45,
                progress: _backdropReveal.value,
                child: child!,
              ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              BrandGlow(animation: _glowScale),
              AnimatedBrandLogo(
                tint: AppColor.surface,
                shimmerColor: AppColor.orange,
                delay: const Duration(milliseconds: 260),
                onIntroEnd: _handleIntroEnd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
