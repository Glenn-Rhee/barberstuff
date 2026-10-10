import 'package:flutter/material.dart';

// Ikon PNG satu warna, ikut [color] / IconTheme. [tint] false = warna asli
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size,
    this.color,
    this.tint = true,
  });

  final String asset;
  final double? size;
  final Color? color;
  final bool tint;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = this.size ?? theme.size ?? 20;

    // Center supaya ukuran tetap [size] walau parent memaksa lebih besar
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: tint ? color ?? theme.color : null,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
