import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/storage/token_storage.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';

/// Signed-in cashier: token, profile and the store they work at.
class SessionController extends ChangeNotifier {
  SessionController(
    this._auth,
    this._client, [
    this._storage = const TokenStorage(),
  ]);

  final AuthApi _auth;

  /// Every API shares this client, so the token set here signs all requests.
  final ApiClient _client;
  final TokenStorage _storage;

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
      final token = await _storage.read();
      if (token != null && token.isNotEmpty) {
        _client.token = token;
        profile = await _auth.profile();
        role = profile?.role;
      }
    } on ApiException {
      // Expired or revoked; ask for the password again.
      _client.token = null;
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  /// Returns an error message, or `null` when signed in.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    busy = true;
    notifyListeners();
    try {
      final login = await _auth.login(email: email, password: password);
      _client.token = login.token;
      role = login.role;
      profile = await _auth.profile();
      await _storage.save(login.token);
      return null;
    } on ApiException catch (e) {
      _client.token = null;
      profile = null;
      return e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // hapus token, profile, role, dan storage saat sign out
  Future<void> signOut() async {
    _client.token = null;
    profile = null;
    role = null;
    await _storage.delete();
    notifyListeners();
  }
}
