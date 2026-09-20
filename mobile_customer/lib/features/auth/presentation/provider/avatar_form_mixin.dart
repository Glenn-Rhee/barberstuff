import 'dart:io';

import 'package:flutter/material.dart';

mixin AvatarFormMixin on ChangeNotifier {
  File? _imageFile;
  String? _imageUrl;

  File? get imageFile => _imageFile;

  String? get imageUrl => _imageUrl;

  bool get hasAvatar => _imageFile != null || _imageUrl != null;

  @protected
  set initialImageUrl(String? value) => _imageUrl = value;

  void setImageFile(File file) {
    _imageFile = file;
    notifyListeners();
  }

  void clearImage() {
    _imageFile = null;
    _imageUrl = null;
    notifyListeners();
  }
}
