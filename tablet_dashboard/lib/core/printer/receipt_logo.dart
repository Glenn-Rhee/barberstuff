import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'esc_pos.dart';

/// The Barberstuff wordmark (same artwork as the app splash), converted to a
/// 1-bit bitmap so the printer can put it on top of the receipt.
class ReceiptLogo {
  const ReceiptLogo._();

  static const asset = 'assets/images/receipt_logo.png';

  /// Dots across on 58mm paper (384 max); a multiple of 8.
  static const printWidth = 320;

  static RasterImage? _cached;

  /// Loaded once at startup; `null` means the receipt falls back to plain text.
  static RasterImage? get cached => _cached;

  static Future<RasterImage?> load({AssetBundle? bundle}) async {
    if (_cached != null) return _cached;
    try {
      final data = await (bundle ?? rootBundle).load(asset);
      return _cached = await decode(data.buffer.asUint8List(), width: printWidth);
    } catch (_) {
      return null;
    }
  }

  /// Scales [bytes] to [width] dots and thresholds it to black and white.
  static Future<RasterImage> decode(Uint8List bytes, {required int width}) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    final height = image.height;
    image.dispose();
    codec.dispose();

    // A logo drawn in white on a transparent background has no dark pixels, so
    // for that artwork every opaque pixel becomes ink instead.
    var opaque = 0;
    var luminanceSum = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      if (rgba[i + 3] < 128) continue;
      opaque++;
      luminanceSum += (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
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
        final luminance = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
        if (lightArtwork || luminance < 160) {
          bits[y * bytesPerRow + (x >> 3)] |= 0x80 >> (x & 7);
        }
      }
    }
    return RasterImage(width: width, height: height, bits: bits);
  }
}
