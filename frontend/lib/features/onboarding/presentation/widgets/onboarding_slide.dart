import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/onboarding/domain/onboarding_content.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.content,
    required this.offset,
  });

  static const double _parallax = 90;

  static const double _textPadding = 32;

  static const double _fadeStart = 0.52;

  static const double _fadeEnd = 0.94;

  final OnboardingContent content;

  final double offset;

  @override
  Widget build(BuildContext context) {
    final double t = offset.clamp(-1.0, 1.0);
    final double fade = (1 - t.abs()).clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        Expanded(
          child: Transform.translate(
            offset: Offset(t * _parallax, 0),
            child: Opacity(
              opacity: fade,
              child: SizedBox.expand(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xFF000000),
                      Color(0x66000000),
                      Color(0x00000000),
                    ],
                    stops: <double>[_fadeStart, 0.78, _fadeEnd],
                  ).createShader(bounds),
                  child: Image.asset(
                    content.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(_textPadding, 0, _textPadding, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                content.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                content.description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
