import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Foto cabang dari URL presigned backend, atau [bytes] hasil pilih galeri.
// Kosong / gagal dimuat (link kedaluwarsa 30 menit) = ikon toko abu-abu
class BranchBanner extends StatelessWidget {
  const BranchBanner({
    super.key,
    this.url,
    this.bytes,
    this.height,
    this.radius = BorderRadius.zero,
  });

  final String? url;
  final Uint8List? bytes;
  final double? height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      color: AppColor.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_outlined,
        size: 36,
        color: AppColor.inkFaint,
      ),
    );
    final bytes = this.bytes;
    final url = this.url;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover)
            : url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                frameBuilder: (_, child, frame, loadedSync) =>
                    frame == null && !loadedSync ? placeholder : child,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
