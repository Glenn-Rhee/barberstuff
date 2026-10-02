// Satu baris hasil cetak, dibaca balik dari byte ESC/POS
class PrintedLine {
  const PrintedLine(this.text, {required this.large, required this.bold});

  final String text;
  final bool large;
  final bool bold;

  // Batas karakter per baris sesuai ukuran font
  int get maxWidth => large ? 16 : 32;
}

// Baca balik perintah ESC/POS yang dibuat EscPos,
// supaya tes bisa cek apa yang benar-benar tercetak
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

// Baris 32 kolom yang diharapkan, biar tidak hitung spasi manual
String row(String left, String right) =>
    '$left${' ' * (32 - left.length - right.length)}$right';
