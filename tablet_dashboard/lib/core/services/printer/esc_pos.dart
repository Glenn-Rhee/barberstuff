import 'dart:typed_data';

enum PosAlign { left, center, right }

// Bitmap 1-bit untuk perintah GS v 0: 1 bit per titik, 1 = hitam
class RasterImage {
  const RasterImage({
    required this.width,
    required this.height,
    required this.bits,
  });

  // Lebar titik, kelipatan 8 dan maks 384 untuk kertas 58mm
  final int width;
  final int height;
  final Uint8List bits;

  int get bytesPerRow => width ~/ 8;
}

// Perintah ESC/POS printer 58mm: 384 titik, 32 karakter per baris
class EscPos {
  EscPos({this.lineWidth = 32}) {
    _bytes.add(const [0x1B, 0x40]); // ESC @ : reset printer
  }

  final int lineWidth;
  final BytesBuilder _bytes = BytesBuilder(copy: false);

  void text(
    String value, {
    PosAlign align = PosAlign.left,
    bool bold = false,
    bool large = false,
  }) {
    _bytes
      ..add([0x1B, 0x61, align.index]) // ESC a n : rata teks
      ..add([0x1B, 0x45, bold ? 1 : 0]) // ESC E n : tebal
      ..add([0x1D, 0x21, large ? 0x11 : 0x00]) // GS ! n : ukuran 2x
      ..add(_encode(value))
      ..addByte(0x0A) // LF : cetak baris
      ..add(const [
        0x1B,
        0x61,
        0,
        0x1B,
        0x45,
        0,
        0x1D,
        0x21,
        0,
      ]); // balik ke default
  }

  // [left] di kiri, [right] di kanan, tidak muat = dua baris
  void row(String left, String right, {bool bold = false}) {
    final gap = lineWidth - left.length - right.length;
    if (gap < 1) {
      text(left, bold: bold);
      text(right, align: PosAlign.right, bold: bold);
      return;
    }
    text('$left${' ' * gap}$right', bold: bold);
  }

  // Teks panjang (mis. alamat) dipotong per kata supaya tidak keluar kertas
  void paragraph(
    String value, {
    PosAlign align = PosAlign.left,
    bool bold = false,
  }) {
    for (final line in wrap(value, lineWidth)) {
      text(line, align: align, bold: bold);
    }
  }

  // Cetak bitmap (GS v 0), mis. logo di atas struk
  void raster(RasterImage image, {PosAlign align = PosAlign.center}) {
    final bytesPerRow = image.bytesPerRow;
    _bytes
      ..add([0x1B, 0x61, align.index]) // ESC a n : rata
      ..add([
        0x1D, 0x76, 0x30, 0x00, // GS v 0 m : gambar raster ukuran normal
        bytesPerRow & 0xFF, (bytesPerRow >> 8) & 0xFF,
        image.height & 0xFF, (image.height >> 8) & 0xFF,
      ])
      ..add(image.bits)
      ..add(const [0x1B, 0x61, 0]);
  }

  void divider([String char = '-']) => text(char * lineWidth);

  void feed([int lines = 1]) => _bytes.add([0x1B, 0x64, lines]); // ESC d n

  Uint8List build() => _bytes.toBytes();

  static List<String> wrap(String value, int width) {
    final lines = <String>[];
    var current = '';
    for (final word in value.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      if (current.isEmpty) {
        current = word;
      } else if (current.length + 1 + word.length <= width) {
        current = '$current $word';
      } else {
        lines.add(current);
        current = word;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }

  // Code page bawaan printer PC437, selain ASCII jadi '?'
  static List<int> _encode(String value) => [
    for (final rune in value.runes) (rune >= 0x20 && rune < 0x7F) ? rune : 0x3F,
  ];
}
