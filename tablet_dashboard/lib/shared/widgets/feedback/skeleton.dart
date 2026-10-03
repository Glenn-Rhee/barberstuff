import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Kerangka abu-abu berdenyut selama data dimuat. Isi [child] dengan
// SkeletonBox yang meniru bentuk konten aslinya
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final _opacity = Tween(begin: 0.45, end: 1.0).animate(_pulse);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ExcludeSemantics(child: widget.child),
    );
  }
}

// Satu kotak kerangka. Tanpa [width] = selebar tempatnya
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 12, this.radius = 6});

  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size / 2;

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

// Lebar baris teks yang berganti-ganti biar tidak kaku
double _lineWidth(int i) => const [0.8, 0.55, 0.7, 0.45, 0.65][i % 5];

// Baris tabel kerangka. [flex] sama dengan kolom tabel aslinya,
// kolom terakhir berbentuk tombol / badge
class SkeletonRows extends StatelessWidget {
  const SkeletonRows({
    super.key,
    required this.flex,
    this.count = 6,
    this.rowHeight = 56,
    this.avatar = false,
  });

  final List<int> flex;
  final int count;
  final double rowHeight;

  // Kolom pertama pakai foto bulat + dua baris (nama, kode)
  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        children: [
          for (var i = 0; i < count; i++)
            Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColor.border)),
              ),
              child: Row(
                children: [
                  for (final (j, f) in flex.indexed)
                    Expanded(
                      flex: f,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: switch (j) {
                          0 when avatar => const _AvatarLines(),
                          _ when j == flex.length - 1 => const SkeletonBox(
                            width: 64,
                            height: 26,
                            radius: 13,
                          ),
                          _ => FractionallySizedBox(
                            widthFactor: _lineWidth(i + j),
                            child: const SkeletonBox(),
                          ),
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarLines extends StatelessWidget {
  const _AvatarLines();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox.circle(size: 32),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(widthFactor: 0.8, child: SkeletonBox()),
              SizedBox(height: 6),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: SkeletonBox(height: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Kartu kerangka dalam grid (layanan, pelanggan, capster)
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    this.count = 8,
    this.spacing = 12,
    this.avatar = false,
  });

  final int crossAxisCount;
  final double mainAxisExtent;
  final int count;
  final double spacing;

  // Kartu orang (foto bulat di tengah) atau kartu layanan (ikon di kiri)
  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: mainAxisExtent,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: count,
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.border),
          ),
          child: Column(
            crossAxisAlignment: avatar
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (avatar)
                const SkeletonBox.circle(size: 56)
              else
                const SkeletonBox(width: 40, height: 40, radius: 10),
              const SizedBox(height: 14),
              SkeletonBox(width: 90 + (i % 3) * 20, height: 14),
              const SizedBox(height: 8),
              const SkeletonBox(width: 70, height: 10),
              const Spacer(),
              const SkeletonBox(height: 32, radius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Daftar kerangka: foto bulat + dua baris + badge (capster, booking, printer)
class SkeletonTiles extends StatelessWidget {
  const SkeletonTiles({
    super.key,
    this.count = 4,
    this.avatar = true,
    this.trailing = true,
  });

  final int count;
  final bool avatar;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (avatar) ...[
                    const SkeletonBox.circle(size: 36),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: _lineWidth(i),
                          child: const SkeletonBox(),
                        ),
                        const SizedBox(height: 6),
                        const FractionallySizedBox(
                          widthFactor: 0.4,
                          child: SkeletonBox(height: 10),
                        ),
                      ],
                    ),
                  ),
                  if (trailing) ...[
                    const SizedBox(width: 12),
                    const SkeletonBox(width: 56, height: 22, radius: 11),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Kartu kerangka berisi judul + beberapa baris, tinggi tetap
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.height, this.lines = 3});

  final double height;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: 14),
          for (var i = 0; i < lines; i++) ...[
            const SizedBox(height: 14),
            FractionallySizedBox(
              widthFactor: _lineWidth(i + 1),
              child: const SkeletonBox(),
            ),
          ],
        ],
      ),
    );
  }
}
