import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const String _emailKey = 'remembered_email';
  static const String _tokenKey = 'access_token';
  static const String _expiresAtKey = 'access_token_expires_at';

  static const Duration fallbackLifetime = Duration(days: 30);

  String? _rememberedEmail;
  String? _accessToken;
  DateTime? _expiresAt;

  String? get rememberedEmail => _rememberedEmail;
  DateTime? get expiresAt => _expiresAt;

  bool get hasValidSession =>
      _accessToken != null &&
      _accessToken!.isNotEmpty &&
      _expiresAt != null &&
      _expiresAt!.isAfter(DateTime.now());

  String? get accessToken => hasValidSession ? _accessToken : null;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _rememberedEmail = prefs.getString(_emailKey);
    _accessToken = prefs.getString(_tokenKey);

    final int? millis = prefs.getInt(_expiresAtKey);
    _expiresAt = millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis);

    if (_accessToken != null && !hasValidSession) await clearSession();
  }

  Future<void> saveSession(String token) async {
    if (token.isEmpty) return;

    _accessToken = token;
    _expiresAt = expiryOf(token) ?? DateTime.now().add(fallbackLifetime);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_expiresAtKey, _expiresAt!.millisecondsSinceEpoch);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _expiresAt = null;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiresAtKey);
  }

  Future<void> rememberEmail(String? email) async {
    _rememberedEmail = email;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (email == null || email.isEmpty) {
      await prefs.remove(_emailKey);
      return;
    }
    await prefs.setString(_emailKey, email);
  }

  static DateTime? expiryOf(String token) {
    final List<String> parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final Object? payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return null;

      final Object? exp = payload['exp'];
      if (exp is! int) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return null;
    }
  }
}
