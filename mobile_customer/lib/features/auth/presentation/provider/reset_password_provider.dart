import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/reset_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

/// Hasil akhir tombol simpan pada halaman kata sandi baru.
///
/// `/auth/reset` tidak mengembalikan access token, jadi setelah reset berhasil
/// halaman ini login ulang memakai kata sandi baru agar bisa langsung masuk
/// beranda. Login itu bisa gagal sendiri walaupun kata sandinya sudah berganti,
/// dan [signedOut] membedakan kasus tersebut dari reset yang memang gagal.
enum ResetOutcome { failed, signedIn, signedOut }

class ResetPasswordProvider extends ChangeNotifier {
  ResetPasswordProvider(
    this._repository,
    this._session, {
    required this.email,
    required this.resetToken,
  }) {
    passwordController.addListener(_syncComplete);
    confirmController.addListener(_syncComplete);
  }

  final AuthRepository _repository;
  final AppSession _session;
  final String email;
  final String resetToken;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isComplete = false;
  ApiException? _error;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  ApiException? get error => _error;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void _syncComplete() {
    final bool next =
        passwordController.text.isNotEmpty && confirmController.text.isNotEmpty;

    if (_isComplete != next) {
      _isComplete = next;
      notifyListeners();
    }
  }

  Future<ResetOutcome> submit() async {
    if (_isLoading) return ResetOutcome.failed;
    if (!(formKey.currentState?.validate() ?? false)) {
      return ResetOutcome.failed;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final String password = passwordController.text;

    try {
      await _repository.resetPassword(
        ResetPasswordRequestApi(resetToken: resetToken, newPassword: password),
      );
    } on ApiException catch (e) {
      _isLoading = false;
      _error = e;
      notifyListeners();
      return ResetOutcome.failed;
    }

    // Kata sandi sudah berganti sejak titik ini. Kegagalan login di bawah tidak
    // membatalkan reset, jadi jangan laporkan sebagai reset yang gagal.
    try {
      final LoginResult result = await _repository.login(
        LoginRequestApi(email: email, password: password),
      );
      await _session.rememberEmail(_rememberMe ? email : null);
      await _session.saveSession(result.accessToken);

      _isLoading = false;
      notifyListeners();
      return ResetOutcome.signedIn;
    } on ApiException catch (e) {
      _isLoading = false;
      _error = e;
      notifyListeners();
      return ResetOutcome.signedOut;
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
