import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_barberstuff/core/config/env.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';

class GoogleCredential {
  const GoogleCredential({required this.idToken, this.photoUrl});

  final String idToken;
  final String? photoUrl;
}

class GoogleAuthService {
  GoogleAuthService();

  Future<void>? _ready;

  static final RegExp _platformErrorCode = RegExp(r'\[\d+\]');

  Future<void> _ensureReady() async {
    try {
      await (_ready ??= GoogleSignIn.instance.initialize(
        serverClientId: Env.CLIENT_ID,
      ));
    } catch (_) {
      _ready = null;
      rethrow;
    }
  }

  Never _fail(String reason) {
    if (kDebugMode) {
      debugPrint('[GoogleAuthService] gagal -> $reason');
      debugPrint('[GoogleAuthService] serverClientId=${Env.CLIENT_ID}');
    }
    throw const ApiException(ApiErrorType.google);
  }

  Future<GoogleSignInAccount?> _lightweightSignIn() async {
    if (kDebugMode) debugPrint('[GoogleAuthService] coba one-tap');

    final Future<GoogleSignInAccount?>? attempt = GoogleSignIn.instance
        .attemptLightweightAuthentication();
    if (attempt == null) return null;

    try {
      final GoogleSignInAccount? account = await attempt;
      if (kDebugMode) {
        debugPrint(
          '[GoogleAuthService] one-tap -> ${account?.email ?? 'null'}',
        );
      }
      return account;
    } catch (e) {
      if (kDebugMode) debugPrint('[GoogleAuthService] one-tap gagal -> $e');
      return null;
    }
  }

  Future<GoogleCredential?> signIn() async {
    try {
      await _ensureReady();

      GoogleSignInAccount? account = await _lightweightSignIn();

      if (account == null) {
        if (kDebugMode) debugPrint('[GoogleAuthService] mulai authenticate()');
        account = await GoogleSignIn.instance.authenticate();
      }

      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        _fail('idToken kosong, serverClientId harus id Web client');
      }

      if (kDebugMode) _debugToken(account.email, idToken);

      return GoogleCredential(idToken: idToken, photoUrl: account.photoUrl);
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
    try {
      await _ensureReady();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      if (kDebugMode) debugPrint('[GoogleAuthService] signOut diabaikan -> $e');
    }
  }

  static void _debugToken(String email, String idToken) {
    debugPrint('[GoogleAuthService] akun=$email');

    final List<String> parts = idToken.split('.');
    if (parts.length != 3) return;

    try {
      final Object? payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return;

      final Object? exp = payload['exp'];
      final DateTime? expiresAt = exp is int
          ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          : null;

      debugPrint('[GoogleAuthService] aud=${payload['aud']}');
      debugPrint('[GoogleAuthService] iss=${payload['iss']}');
      debugPrint(
        '[GoogleAuthService] email_verified=${payload['email_verified']}',
      );
      debugPrint('[GoogleAuthService] exp=$expiresAt (now=${DateTime.now()})');
      debugPrint(
        '[GoogleAuthService] aud cocok=${payload['aud'] == Env.CLIENT_ID}',
      );
    } catch (_) {}
  }
}
