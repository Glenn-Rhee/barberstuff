import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// Foto dari galeri tablet, siap diunggah
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class PhotoPickerException implements Exception {
  const PhotoPickerException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Pilih foto galeri, dikecilkan supaya di bawah batas upload 5 MB
class PhotoPicker {
  const PhotoPicker._();

  static Future<PickedPhoto?> pick({double maxSide = 1600}) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: maxSide,
        maxHeight: maxSide,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return PickedPhoto(
        bytes: await picked.readAsBytes(),
        fileName: picked.name,
      );
    } on PlatformException catch (e) {
      throw PhotoPickerException(
        e.code == 'photo_access_denied'
            ? 'Izin akses galeri ditolak'
            : 'Galeri tidak bisa dibuka',
      );
    }
  }
}
