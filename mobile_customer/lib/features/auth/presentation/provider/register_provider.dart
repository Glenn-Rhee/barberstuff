import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/register_account.dart';
import 'package:mobile_barberstuff/shared/mixins/avatar_form_mixin.dart';

class RegisterProvider extends ChangeNotifier with AvatarFormMixin {
  RegisterProvider(this._register) {
    for (final TextEditingController c in _textFields) {
      c.addListener(_syncComplete);
    }
  }

  final RegisterAccount _register;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  List<TextEditingController> get _textFields => <TextEditingController>[
    nameController,
    phoneController,
    emailController,
    passwordController,
  ];

  DateTime? _dateOfBirth;
  String? _gender;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  RegisterResult? _result;
  Registration? _lastRequest;

  Registration? get lastRequest => _lastRequest;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;
  RegisterResult? get result => _result;

  void _syncComplete() {
    final bool next =
        _dateOfBirth != null &&
        _gender != null &&
        _textFields.every(
          (TextEditingController c) => c.text.trim().isNotEmpty,
        );

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

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_dateOfBirth == null || _gender == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final Registration request = Registration(
      name: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _gender!,
      email: emailController.text.trim(),
      password: passwordController.text,
      imageUrl: imageUrl,
    );

    try {
      _result = await _register(request);
      _lastRequest = request;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      return _fail(e);
    }
  }

  bool _fail(ApiException e) {
    _error = e;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
