import 'dart:io';

import 'package:flutter/material.dart';

/// State foto profil yang dipakai bersama oleh alur registrasi kredensial dan
/// alur lengkapi profil OAuth, supaya keduanya bisa memakai satu widget dan
/// satu handler pemilihan gambar.
mixin AvatarFormMixin on ChangeNotifier {
  File? _imageFile;
  String? _imageUrl;

  /// Gambar hasil pilihan pengguna dari galeri atau kamera.
  File? get imageFile => _imageFile;

  /// Foto bawaan akun, saat ini hanya terisi dari profil Google.
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
