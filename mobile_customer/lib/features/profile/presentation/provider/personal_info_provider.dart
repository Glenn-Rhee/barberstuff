import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/services/image_upload_service.dart';
import 'package:mobile_barberstuff/core/utils/date_format.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/usecases/update_customer_profile.dart';
import 'package:mobile_barberstuff/shared/mixins/avatar_form_mixin.dart';

class PersonalInfoProvider extends ChangeNotifier with AvatarFormMixin {
  PersonalInfoProvider(this.profile, this._updateProfile, this._uploader) {
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phoneNumber;
    final DateTime? dateOfBirth = profile.dateOfBirth;
    _dateOfBirth = dateOfBirth;
    if (dateOfBirth != null) {
      birthDateController.text = formatDayMonthYear(dateOfBirth);
    }
    initialImageUrl = profile.imageUrl;

    nameController.addListener(_syncDirty);
    phoneController.addListener(_syncDirty);
  }

  final CustomerProfile profile;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final UpdateCustomerProfile _updateProfile;
  final ImageUploadService _uploader;

  DateTime? _dateOfBirth;
  bool _isDirty = false;
  bool _isSaving = false;
  ApiException? _error;

  DateTime? get dateOfBirth => _dateOfBirth;
  bool get isDirty => _isDirty;
  bool get isSaving => _isSaving;
  ApiException? get error => _error;

  void setDateOfBirth(DateTime value) {
    _dateOfBirth = value;
    birthDateController.text = formatDayMonthYear(value);
    _syncDirty();
    notifyListeners();
  }

  @override
  void setImageFile(File file) {
    super.setImageFile(file);
    _syncDirty();
  }

  @override
  void clearImage() {
    super.clearImage();
    _syncDirty();
  }

  void _syncDirty() {
    final bool next =
        nameController.text.trim() != profile.name ||
        phoneController.text.trim() != profile.phoneNumber ||
        _dateOfBirth != profile.dateOfBirth ||
        imageFile != null ||
        imageUrl != profile.imageUrl;

    if (_isDirty != next) {
      _isDirty = next;
      notifyListeners();
    }
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Future<CustomerProfile?> save() async {
    if (_isSaving) return null;
    if (!validate()) return null;

    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();

    final File? photo = imageFile;

    final Map<String, String> changes = <String, String>{
      if (name != profile.name) 'name': name,
      if (phone != profile.phoneNumber) 'phoneNumber': phone,
    };

    if (changes.isEmpty && photo == null) return profile;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Foto diunggah dulu, lalu object key-nya ikut dalam satu PATCH.
      final String? imageKey = photo == null
          ? null
          : await _uploader.uploadFile(photo);

      return await _updateProfile(
        UpdateCustomerProfileParams(
          name: changes['name'],
          phoneNumber: changes['phoneNumber'],
          imageKey: imageKey,
        ),
      );
    } on ApiException catch (e) {
      _error = e;
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
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
