import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class LoginProvider extends ChangeNotifier {
  LoginProvider(this._repository, this._session) {
    final String? saved = _session.rememberedEmail;
    if (saved != null && saved.isNotEmpty) {
      emailController.text = saved;
      _rememberMe = true;
    }

    emailController.addListener(_syncComplete);
    passwordController.addListener(_syncComplete);
  }

  final AuthRepository _repository;
  final AppSession _session;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isComplete = false;
  String? _errorMessage;
  LoginResult? _result;

  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  String? get errorMessage => _errorMessage;
  LoginResult? get result => _result;

  void _syncComplete() {
    final bool next =
        emailController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty;

    if (_isComplete != next) {
      _isComplete = next;
      notifyListeners();
    }
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String email = emailController.text.trim();

    try {
      _result = await _repository.login(
        LoginRequestApi(email: email, password: passwordController.text),
      );
      await _session.rememberEmail(_rememberMe ? email : null);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
