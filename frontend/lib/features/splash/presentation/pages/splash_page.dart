import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/animated_brand_logo.dart';
import '../../../../shared/widgets/barber_pattern_background.dart';
import '../../../../src/app/app_route.dart';
import '../../../../src/core/constants/app_duration.dart';
import '../../../../theme/app_color.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backdrop;
  late final Animation<double> _backdropReveal;

  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();

    _backdrop = AnimationController(
      vsync: this,
      duration: AppDuration.backdropIntro,
    );

    _backdropReveal = CurvedAnimation(
      parent: _backdrop,
      curve: Curves.easeOutCubic,
    );

    _backdrop.forward();
  }

  @override
  void dispose() {
    _backdrop.dispose();
    super.dispose();
  }

  Future<void> _openBrandSplash() async {
    if (_isLeaving) return;
    _isLeaving = true;

    await Future<void>.delayed(AppDuration.splashHold);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoute.splashBrand);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColor.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.surface,
        body: AnimatedBuilder(
          animation: _backdropReveal,
          builder: (BuildContext context, Widget? child) =>
              BarberPatternBackground(
                backgroundColor: AppColor.surface,
                patternIntensity: 1.2,
                patternScale: 1.25,
                coverage: 0.56,
                fadeSpan: 0.45,
                progress: _backdropReveal.value,
                child: child!,
              ),
          child: Center(
            child: AnimatedBrandLogo(
              delay: const Duration(milliseconds: 200),
              onIntroEnd: _openBrandSplash,
            ),
          ),
        ),
      ),
    );
  }
}
