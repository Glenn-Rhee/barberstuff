import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

/// Pembungkus yang menyapukan kilau ke seluruh kotak skeleton di dalamnya.
/// Satu animasi dipakai bareng, bukan satu per kotak, biar ringan.
class SkeletonGroup extends StatefulWidget {
  const SkeletonGroup({super.key, required this.child});

  static const Duration sweep = Duration(milliseconds: 1400);

  final Widget child;

  @override
  State<SkeletonGroup> createState() => _SkeletonGroupState();
}

class _SkeletonGroupState extends State<SkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SkeletonGroup.sweep,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        // Pita terang bergerak dari kiri ke kanan melewati seluruh area.
        final double t = (_controller.value * 2.4) - 1.2;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(t - 0.45, -0.25),
            end: Alignment(t + 0.45, 0.25),
            colors: const <Color>[
              AppColor.border,
              AppColor.dotIdle,
              AppColor.border,
            ],
            stops: const <double>[0, 0.5, 1],
          ).createShader(bounds),
          child: child,
        );
      },
      child: IgnorePointer(child: widget.child),
    );
  }
}

/// Satu kotak abu-abu pengganti teks, gambar, atau tombol yang belum datang.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
  });

  /// Bentuk bulat untuk foto profil atau ikon.
  /// Radius sebesar sisi sudah cukup membuat kotak jadi lingkaran.
  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size;

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Baris daftar: gambar kecil di kiri, dua baris teks di kanan.
/// Dipakai di daftar cabang, riwayat, dan pilihan capster.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.thumbSize = 74,
    this.thumbRadius = 10,
    this.lines = 3,
  });

  final double thumbSize;
  final double thumbRadius;
  final int lines;

  @override
  Widget build(BuildContext context) {
    // Baris terakhir sengaja lebih pendek, meniru teks asli yang tak penuh.
    const List<double> widthRatio = <double>[0.62, 0.86, 0.34];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonBox(
            width: thumbSize,
            height: thumbSize,
            radius: thumbRadius,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < lines; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: 8),
                      SkeletonBox(
                        width: c.maxWidth * widthRatio[i % widthRatio.length],
                        height: i == 0 ? 15 : 12,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar skeleton siap pakai, sudah dibungkus SkeletonGroup.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 24),
    this.gap = 12,
    this.itemBuilder,
  });

  final int itemCount;
  final EdgeInsets padding;
  final double gap;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  static Widget _defaultItem(BuildContext context, int index) =>
      const SkeletonListTile();

  @override
  Widget build(BuildContext context) {
    final Widget Function(BuildContext, int) build =
        itemBuilder ?? _defaultItem;

    return SkeletonGroup(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (BuildContext _, int _) => SizedBox(height: gap),
        itemBuilder: build,
      ),
    );
  }
}
