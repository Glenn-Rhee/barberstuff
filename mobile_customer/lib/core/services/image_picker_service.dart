import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum AvatarSource { camera, gallery }

class ImagePickerFailure implements Exception {
  const ImagePickerFailure({required this.permissionDenied});

  final bool permissionDenied;
}

class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _maxSide = 720;
  static const int _quality = 85;

  static const Set<String> _permissionCodes = <String>{
    'camera_access_denied',
    'photo_access_denied',
  };

  Future<File?> pick(AvatarSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source == AvatarSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
        preferredCameraDevice: CameraDevice.front,
      );

      return picked == null ? null : File(picked.path);
    } on PlatformException catch (e) {
      throw ImagePickerFailure(
        permissionDenied: _permissionCodes.contains(e.code),
      );
    }
  }
}
