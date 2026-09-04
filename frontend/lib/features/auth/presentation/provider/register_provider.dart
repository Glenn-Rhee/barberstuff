import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class RegisterProvider extends ChangeNotifier {
  RegisterProvider(this._repository) {
    for (final TextEditingController c in _textFields) {
      c.addListener(_syncComplete);
    }
  }

  final AuthRepository _repository;

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
  String? _imageUrl;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  RegisterResult? _result;
  RegisterRequestApi? _lastRequest;

  RegisterRequestApi? get lastRequest => _lastRequest;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  String? get imageUrl => _imageUrl;
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

  void setImageUrl(String? v) {
    _imageUrl = v;
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

    final RegisterRequestApi request = RegisterRequestApi(
      name: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _gender!,
      email: emailController.text.trim(),
      password: passwordController.text,
      imageUrl: _imageUrl,
    );

    try {
      _result = await _repository.register(request);
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