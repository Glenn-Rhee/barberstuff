import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/services/printer/esc_pos.dart';

// Logo Barberstuff diubah jadi bitmap 1-bit untuk kepala struk
class ReceiptLogo {
  const ReceiptLogo._();

  static const asset = AppAsset.logoWordmark;

  // Lebar cetak dalam titik (maks 384), kelipatan 8
  static const printWidth = 320;

  static RasterImage? _cached;

  // Dimuat sekali saat login; null = struk pakai nama toko biasa
  static RasterImage? get cached => _cached;

  static Future<RasterImage?> load({AssetBundle? bundle}) async {
    if (_cached != null) return _cached;
    try {
      final data = await (bundle ?? rootBundle).load(asset);
      return _cached = await decode(
        data.buffer.asUint8List(),
        width: printWidth,
      );
    } catch (_) {
      return null;
    }
  }

  // Skala gambar ke [width] titik lalu ubah jadi hitam-putih
  static Future<RasterImage> decode(
    Uint8List bytes, {
    required int width,
  }) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    final height = image.height;
    image.dispose();
    codec.dispose();

    // Logo putih di latar transparan tidak punya piksel gelap,
    // jadi semua piksel yang tidak transparan dianggap tinta
    var opaque = 0;
    var luminanceSum = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      if (rgba[i + 3] < 128) continue;
      opaque++;
      luminanceSum +=
          (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
    }
    final lightArtwork = opaque > 0 && luminanceSum / opaque > 170;

    final bytesPerRow = width ~/ 8;
    final bits = Uint8List(bytesPerRow * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        if (i + 3 >= rgba.length) continue;
        final alpha = rgba[i + 3];
        if (alpha < 128) continue;
        final luminance =
            (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
        if (lightArtwork || luminance < 160) {
          bits[y * bytesPerRow + (x >> 3)] |= 0x80 >> (x & 7);
        }
      }
    }
    return RasterImage(width: width, height: height, bits: bits);
  }
}
