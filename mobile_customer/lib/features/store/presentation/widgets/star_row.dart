import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 13});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Image.asset(
              star <= rating
                  ? AppAssets.starHistoryFilled
                  : AppAssets.starHistoryEmpty,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
      ],
    );
  }
}
