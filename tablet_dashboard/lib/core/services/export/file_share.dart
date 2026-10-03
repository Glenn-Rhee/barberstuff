import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Simpan file ke folder sementara lalu buka menu bagikan Android
// (simpan ke Files / Drive / kirim WhatsApp)
class FileShare {
  const FileShare._();

  static Future<void> pdf(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: fileName,
      ),
    );
  }
}
