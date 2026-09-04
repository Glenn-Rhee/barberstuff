import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/auth/data/models/forgot_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  ForgotPasswordProvider(this._repository) {
    emailController.addListener(_syncComplete);
  }

  final AuthRepository _repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;
  ForgotPasswordResult? _result;

  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;
  ForgotPasswordResult? get result => _result;

  String get email => emailController.text.trim();

  void _syncComplete() {
    final bool next = email.isNotEmpty;
    if (_isComplete != next) {
      _isComplete = next;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (_isLoading) return false;
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.forgotPassword(
        ForgotPasswordRequestApi(email: email),
      );
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
    super.dispose();
  }
}
