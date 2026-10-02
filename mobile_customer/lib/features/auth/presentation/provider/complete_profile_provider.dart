import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/services/image_upload_service.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/core/utils/date_format.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/complete_google_registration.dart';
import 'package:mobile_barberstuff/features/profile/domain/usecases/update_customer_profile.dart';
import 'package:mobile_barberstuff/shared/mixins/avatar_form_mixin.dart';

class CompleteProfileProvider extends ChangeNotifier with AvatarFormMixin {
  CompleteProfileProvider(
    this._completeRegistration,
    this._session,
    this._uploader,
    this._updateProfile, {
    required this.name,
    required this.email,
    required this.tempToken,
    String? imageUrl,
  }) {
    nameController.text = name;
    emailController.text = email;
    initialImageUrl = imageUrl;
    nameController.addListener(_syncComplete);
    phoneController.addListener(_syncComplete);
  }

  final CompleteGoogleRegistration _completeRegistration;
  final AppSession _session;
  final ImageUploadService _uploader;
  final UpdateCustomerProfile _updateProfile;
  final String name;
  final String email;
  final String tempToken;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  LoginResult? _result;

  DateTime? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;
  LoginResult? get result => _result;

  void _syncComplete() {
    final bool next =
        _dateOfBirth != null &&
        _gender != null &&
        nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty;

    if (_isComplete != next) {
      _isComplete = next;
      notifyListeners();
    }
  }

  void setDateOfBirth(DateTime v) {
    _dateOfBirth = v;
    birthDateController.text = formatDayMonthYear(v);
    _syncComplete();
    notifyListeners();
  }

  void setGender(String? v) {
    _gender = v;
    _syncComplete();
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_dateOfBirth == null || _gender == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _completeRegistration(
        CompleteGoogleRegistrationParams(
          name: nameController.text.trim(),
          tempToken: tempToken,
          phoneNumber: phoneController.text.trim(),
          dateOfBirth: _dateOfBirth!,
          gender: _gender!,
        ),
      );
      await _session.saveSession(_result!.accessToken);
      await _saveAvatar();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      _error = e;
      notifyListeners();
      return false;
    }
  }

  /// `image_url` tidak ikut saat daftar: backend hanya menerima object key,
  /// sedangkan presign butuh token yang baru ada sesudah akun jadi. Jadi foto
  /// (pilihan sendiri atau foto akun Google) diunggah lalu dipasang di sini.
  ///
  /// Akun sudah jadi, jadi gagal unggah foto tidak boleh menggagalkan
  /// pendaftaran. Fotonya masih bisa diganti dari halaman profil.
  Future<void> _saveAvatar() async {
    final File? file = imageFile;
    final String? url = imageUrl;
    if (file == null && url == null) return;

    try {
      final String key = file != null
          ? await _uploader.uploadFile(file)
          : await _uploader.uploadFromUrl(url!);
      await _updateProfile(UpdateCustomerProfileParams(imageKey: key));
    } on ApiException catch (e) {
      debugPrint('Simpan foto profil gagal: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
