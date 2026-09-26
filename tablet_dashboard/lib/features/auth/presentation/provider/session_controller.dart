import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../data/api/barberstuff_api.dart';
import '../../../../shared/models/person.dart';

/// Signed-in cashier: token, profile and the store they work at.
class SessionController extends ChangeNotifier {
  SessionController(this._api);

  static const _tokenKey = 'access_token';

  final BarberstuffApi _api;

  StaffProfile? profile;
  String? role;

  /// True while an existing token is being checked at startup.
  bool restoring = true;
  bool busy = false;

  bool get signedIn => profile != null;
  String get storeId => profile?.storeId ?? '';

  /// Reuses the token from the last session so the till survives a restart.
  Future<void> restore() async {
    try {
      final token = (await SharedPreferences.getInstance()).getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        _api.client.token = token;
        profile = await _api.profile();
        role = profile?.role;
      }
    } on ApiException {
      _api.client.token = null; // expired or revoked; ask for the password again
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  /// Returns an error message, or `null` when signed in.
  Future<String?> signIn({required String email, required String password}) async {
    busy = true;
    notifyListeners();
    try {
      final login = await _api.login(email: email, password: password);
      _api.client.token = login.token;
      role = login.role;
      profile = await _api.profile();
      (await SharedPreferences.getInstance()).setString(_tokenKey, login.token);
      return null;
    } on ApiException catch (e) {
      _api.client.token = null;
      profile = null;
      return e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _api.client.token = null;
    profile = null;
    role = null;
    (await SharedPreferences.getInstance()).remove(_tokenKey);
    notifyListeners();
  }
}
