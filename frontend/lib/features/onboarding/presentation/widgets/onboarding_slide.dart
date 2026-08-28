import 'package:flutter/material.dart';

import '../../../../theme/app_color.dart';
import '../../../../theme/app_text_style.dart';
import '../../domain/onboarding_content.dart';

const ColorFilter _grayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.content,
    required this.offset,
  });

  final OnboardingContent content;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final double distance = offset.abs().clamp(0.0, 1.0);
    final double contentOpacity = (1 - distance * 1.6).clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        Expanded(flex: 72, child: _photo(context)),
        Expanded(
          flex: 28,
          child: Opacity(
            opacity: contentOpacity,
            child: Transform.translate(
              offset: Offset(0, distance * 40),
              child: _text(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photo(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.translate(
            offset: Offset(offset * width * 0.3, 0),
            child: ColorFiltered(
              colorFilter: _grayscale,
              child: Image.asset(
                content.image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stack) =>
                        const ColoredBox(color: Color(0xFF9E9E9E)),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x00FFFFFF),
                  Color(0x66FFFFFF),
                  Color(0xFFFFFFFF),
                ],
                stops: <double>[0.65, 0.88, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _text() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: '${content.title} ',
              children: <InlineSpan>[
                TextSpan(
                  text: content.highlight,
                  style: const TextStyle(color: AppColor.orangeLight),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyle.onboardingTitle,
          ),
          const SizedBox(height: 12),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: AppTextStyle.onboardingBody,
          ),
        ],
      ),
    );
  }
}
