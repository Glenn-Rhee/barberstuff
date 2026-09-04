import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_barberstuff/core/config/env.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';

class GoogleAuthService {
  GoogleAuthService();

  Future<void>? _ready;

  static final RegExp _platformErrorCode = RegExp(r'\[\d+\]');

  Future<void> _ensureReady() {
    return _ready ??= GoogleSignIn.instance.initialize(
      serverClientId: Env.CLIENT_ID,
    );
  }

  Never _fail(String reason) {
    if (kDebugMode) {
      debugPrint('[GoogleAuthService] gagal -> $reason');
      debugPrint('[GoogleAuthService] serverClientId=${Env.CLIENT_ID}');
    }
    throw const ApiException(ApiErrorType.google);
  }

  Future<String?> signIn() async {
    try {
      await _ensureReady();
      if (kDebugMode) debugPrint('[GoogleAuthService] mulai authenticate()');

      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      if (kDebugMode) {
        debugPrint('[GoogleAuthService] akun=${account.email}');
      }
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        _fail('idToken kosong, serverClientId harus id Web client');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[GoogleAuthService] ${e.code.name} | ${e.description} | ${e.details}',
        );
      }
      final bool dismissedByUser =
          e.code == GoogleSignInExceptionCode.canceled &&
          !_platformErrorCode.hasMatch(e.description ?? '');

      if (dismissedByUser) return null;
      _fail('${e.code.name}: ${e.description}');
    } catch (e) {
      _fail('$e');
    }
  }

  Future<void> signOut() async {
    await _ensureReady();
    await GoogleSignIn.instance.signOut();
  }
}
