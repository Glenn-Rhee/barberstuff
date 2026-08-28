import 'package:flutter/material.dart';

import '../../domain/onboarding_content.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.content,
    required this.offset,
  });

  final OnboardingContent content;

  /// 0 = di tengah layar, -1 = belum masuk (kanan), 1 = sudah keluar (kiri).
  final double offset;

  @override
  Widget build(BuildContext context) {
    final double t = offset.clamp(-1.0, 1.0);
    final double fade = (1 - t.abs()).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Hanya gambar yang beranimasi (parallax + fade).
          // Perbesar angka 90 untuk efek lebih kuat, perkecil untuk lebih halus.
          Transform.translate(
            offset: Offset(t * 90, 0),
            child: Opacity(
              opacity: fade,
              child: Image.asset(
                content.image,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Teks tanpa animasi tambahan.
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}