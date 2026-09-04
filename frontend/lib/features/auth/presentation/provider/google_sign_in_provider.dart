import 'package:flutter/material.dart';

import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/features/auth/data/models/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';

class GoogleSignInProvider extends ChangeNotifier {
  GoogleSignInProvider(this._repository, this._google, this._session);

  final AuthRepository _repository;
  final GoogleAuthService _google;
  final AppSession _session;

  bool _isLoading = false;
  ApiException? _error;
  AuthProviderResult? _result;

  bool get isLoading => _isLoading;
  ApiException? get error => _error;
  AuthProviderResult? get result => _result;

  Future<bool> signIn() async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      final String? idToken = await _google.signIn();
      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _result = await _repository.authProvider(idToken);

      final String? token = _result!.accessToken;
      if (_result!.status == AuthProviderStatus.success && token != null) {
        await _session.saveSession(token);
      }

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
}
