import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/login_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/login_with_email.dart';

class LoginProvider extends ChangeNotifier {
  LoginProvider(this._login, this._session) {
    final String? saved = _session.rememberedEmail;
    if (saved != null && saved.isNotEmpty) {
      emailController.text = saved;
      _rememberMe = true;
    }

    emailController.addListener(_syncComplete);
    passwordController.addListener(_syncComplete);
  }

  final LoginWithEmail _login;
  final AppSession _session;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  LoginResult? _result;

  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;
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
    _error = null;
    notifyListeners();

    final String email = emailController.text.trim();

    try {
      _result = await _login(
        LoginParams(email: email, password: passwordController.text),
      );
      await _session.rememberEmail(_rememberMe ? email : null);
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
