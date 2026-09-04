import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/oauth_register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class CompleteProfileProvider extends ChangeNotifier {
  CompleteProfileProvider(
    this._repository,
    this._session, {
    required this.name,
    required this.email,
    required this.tempToken,
  }) {
    nameController.text = name;
    emailController.text = email;
    phoneController.addListener(_syncComplete);
  }

  final AuthRepository _repository;
  final AppSession _session;
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
  String? _imageUrl;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  LoginResult? _result;

  DateTime? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  String? get imageUrl => _imageUrl;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;
  LoginResult? get result => _result;

  void _syncComplete() {
    final bool next =
        _dateOfBirth != null &&
        _gender != null &&
        phoneController.text.trim().isNotEmpty;

    if (_isComplete != next) {
      _isComplete = next;
      notifyListeners();
    }
  }

  void setDateOfBirth(DateTime v) {
    _dateOfBirth = v;
    String two(int n) => n.toString().padLeft(2, '0');
    birthDateController.text = '${two(v.day)}/${two(v.month)}/${v.year}';
    _syncComplete();
    notifyListeners();
  }

  void setGender(String? v) {
    _gender = v;
    _syncComplete();
    notifyListeners();
  }

  void setImageUrl(String? v) {
    _imageUrl = v;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_dateOfBirth == null || _gender == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.registerOauth(
        OauthRegisterRequestApi(
          name: name,
          tempToken: tempToken,
          phoneNumber: phoneController.text.trim(),
          dateOfBirth: _dateOfBirth!,
          gender: _gender!,
          imageUrl: _imageUrl,
        ),
      );
      await _session.saveSession(_result!.accessToken);
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
