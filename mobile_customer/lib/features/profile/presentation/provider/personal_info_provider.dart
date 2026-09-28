import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/avatar_form_mixin.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';

class PersonalInfoProvider extends ChangeNotifier with AvatarFormMixin {
  PersonalInfoProvider(this.profile, this._repository) {
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phoneNumber;
    _dateOfBirth = profile.dateOfBirth;
    if (_dateOfBirth != null) birthDateController.text = _format(_dateOfBirth!);
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
  final ProfileRepository _repository;

  DateTime? _dateOfBirth;
  bool _isDirty = false;
  bool _isSaving = false;
  ApiException? _error;

  DateTime? get dateOfBirth => _dateOfBirth;
  bool get isDirty => _isDirty;
  bool get isSaving => _isSaving;
  ApiException? get error => _error;
  bool get hasUnsavedPhoto => imageFile != null;

  void setDateOfBirth(DateTime value) {
    _dateOfBirth = value;
    birthDateController.text = _format(value);
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

    final Map<String, String> changes = <String, String>{
      if (name != profile.name) 'name': name,
      if (phone != profile.phoneNumber) 'phoneNumber': phone,
    };

    if (changes.isEmpty) return profile;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.updateCustomerProfile(
        name: changes['name'],
        phoneNumber: changes['phoneNumber'],
      );
    } on ApiException catch (e) {
      _error = e;
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  static String _format(DateTime v) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(v.day)}/${two(v.month)}/${v.year}';
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
