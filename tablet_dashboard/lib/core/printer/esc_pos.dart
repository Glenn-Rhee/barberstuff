import 'dart:typed_data';

enum PosAlign { left, center, right }

/// A 1-bit bitmap ready for `GS v 0`: one bit per dot, 1 = black,
/// rows padded to whole bytes.
class RasterImage {
  const RasterImage({required this.width, required this.height, required this.bits});

  /// Dots across; a multiple of 8 and at most 384 on 58mm paper.
  final int width;
  final int height;
  final Uint8List bits;

  int get bytesPerRow => width ~/ 8;
}

/// Minimal ESC/POS command builder for 58mm thermal printers.
///
/// 58mm paper = 384 dots; Font A (12x24) fits 32 characters per line,
/// or 16 characters when [text] is called with `large: true`.
class EscPos {
  EscPos({this.lineWidth = 32}) {
    _bytes.add(const [0x1B, 0x40]); // ESC @ : reset printer
  }

  final int lineWidth;
  final BytesBuilder _bytes = BytesBuilder(copy: false);

  void text(String value, {PosAlign align = PosAlign.left, bool bold = false, bool large = false}) {
    _bytes
      ..add([0x1B, 0x61, align.index]) // ESC a n : alignment
      ..add([0x1B, 0x45, bold ? 1 : 0]) // ESC E n : bold
      ..add([0x1D, 0x21, large ? 0x11 : 0x00]) // GS ! n : double width + height
      ..add(_encode(value))
      ..addByte(0x0A) // LF : print line
      ..add(const [0x1B, 0x61, 0, 0x1B, 0x45, 0, 0x1D, 0x21, 0]); // back to defaults
  }

  /// [left] and [right] pushed to opposite edges of one line.
  /// Falls back to two lines when both don't fit.
  void row(String left, String right, {bool bold = false}) {
    final gap = lineWidth - left.length - right.length;
    if (gap < 1) {
      text(left, bold: bold);
      text(right, align: PosAlign.right, bold: bold);
      return;
    }
    text('$left${' ' * gap}$right', bold: bold);
  }

  /// Word-wraps [value] so long text (an address) stays inside the paper width.
  void paragraph(String value, {PosAlign align = PosAlign.left, bool bold = false}) {
    for (final line in wrap(value, lineWidth)) {
      text(line, align: align, bold: bold);
    }
  }

  /// Prints a 1-bit bitmap (GS v 0), e.g. the store logo on the receipt header.
  void raster(RasterImage image, {PosAlign align = PosAlign.center}) {
    final bytesPerRow = image.bytesPerRow;
    _bytes
      ..add([0x1B, 0x61, align.index]) // ESC a n : alignment
      ..add([
        0x1D, 0x76, 0x30, 0x00, // GS v 0 m : raster bit image, normal size
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

  // The printer's default code page is PC437; anything outside printable ASCII becomes '?'.
  static List<int> _encode(String value) => [
    for (final rune in value.runes) (rune >= 0x20 && rune < 0x7F) ? rune : 0x3F,
  ];
}
