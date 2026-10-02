import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

/// Foto cabang dari server. Kalau URL-nya kosong atau gagal dimuat,
/// yang tampil kotak netral, bukan foto cabang lain. Menampilkan foto
/// palsu bikin pengguna mengira itu foto cabang yang sebenarnya.
class StoreImage extends StatelessWidget {
  const StoreImage({super.key, required this.url, this.iconSize = 28});

  final String? url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final String? source = url;

    final Widget blank = ColoredBox(
      color: AppColor.border,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: iconSize,
          color: AppColor.inkFaint,
        ),
      ),
    );

    if (source == null || source.isEmpty) return blank;

    return Image.network(
      source,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (BuildContext _, Object _, StackTrace? _) => blank,
      loadingBuilder:
          (BuildContext _, Widget child, ImageChunkEvent? progress) =>
              progress == null ? child : blank,
    );
  }
}
