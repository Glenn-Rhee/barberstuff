/// A printed line decoded back from ESC/POS bytes.
class PrintedLine {
  const PrintedLine(this.text, {required this.large, required this.bold});

  final String text;
  final bool large;
  final bool bold;

  /// Characters per line the printer can fit for this line's font size.
  int get maxWidth => large ? 16 : 32;
}

/// Decodes the subset of ESC/POS that `EscPos` emits, so tests can
/// check what actually lands on paper.
List<PrintedLine> decodeEscPos(List<int> bytes) {
  final lines = <PrintedLine>[];
  final buffer = StringBuffer();
  var large = false;
  var bold = false;
  var i = 0;
  while (i < bytes.length) {
    final b = bytes[i];
    if (b == 0x1B) {
      final cmd = bytes[i + 1];
      if (cmd == 0x40) {
        i += 2; // ESC @
        continue;
      }
      if (cmd == 0x45) bold = bytes[i + 2] == 1;
      if (cmd == 0x64) {
        for (var n = 0; n < bytes[i + 2]; n++) {
          lines.add(const PrintedLine('', large: false, bold: false));
        }
      }
      i += 3; // ESC a n / ESC E n / ESC d n
    } else if (b == 0x1D) {
      large = bytes[i + 2] == 0x11;
      i += 3; // GS ! n
    } else if (b == 0x0A) {
      lines.add(PrintedLine(buffer.toString(), large: large, bold: bold));
      buffer.clear();
      i++;
    } else {
      buffer.writeCharCode(b);
      i++;
    }
  }
  return lines;
}

/// Expected 32-column row, so tests don't depend on counting spaces by hand.
String row(String left, String right) => '$left${' ' * (32 - left.length - right.length)}$right';
