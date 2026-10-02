import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/sign_in_with_google.dart';

class GoogleSignInProvider extends ChangeNotifier {
  GoogleSignInProvider(this._signIn, this._google, this._session);

  final SignInWithGoogle _signIn;
  final GoogleAuthService _google;
  final AppSession _session;

  bool _isLoading = false;
  ApiException? _error;
  AuthProviderResult? _result;
  String? _photoUrl;

  bool get isLoading => _isLoading;
  ApiException? get error => _error;
  AuthProviderResult? get result => _result;
  String? get photoUrl => _photoUrl;

  bool _stop({ApiException? error}) {
    _isLoading = false;
    _error = error;
    notifyListeners();
    return false;
  }

  Future<bool> signIn() async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      final GoogleCredential? credential = await _google.signIn();
      if (credential == null) return _stop();

      final AuthProviderResult result = await _signIn(credential.idToken);

      final String token = result.accessToken ?? '';
      final String tempToken = result.tempToken ?? '';

      switch (result.status) {
        case AuthProviderStatus.success:
          if (token.isEmpty) {
            return _stop(error: const ApiException(ApiErrorType.server));
          }
          await _session.saveSession(token);
        case AuthProviderStatus.needCompleteProfile:
          if (tempToken.isEmpty) {
            return _stop(error: const ApiException(ApiErrorType.server));
          }
        case AuthProviderStatus.unknown:
          return _stop(error: const ApiException(ApiErrorType.server));
      }

      _result = result;
      _photoUrl = credential.photoUrl;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      return _stop(error: e);
    }
  }
}
