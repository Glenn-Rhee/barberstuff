import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedPayload {
  const CachedPayload({required this.value, required this.savedAt});

  final Object? value;
  final DateTime savedAt;

  Map<String, dynamic>? get asMap =>
      value is Map<String, dynamic> ? value as Map<String, dynamic> : null;

  List<Map<String, dynamic>> get asList => value is List
      ? (value as List<dynamic>).whereType<Map<String, dynamic>>().toList(
          growable: false,
        )
      : const <Map<String, dynamic>>[];
}

class CachedResult<T> {
  const CachedResult(this.data, {required this.fromCache, this.savedAt});

  final T data;
  final bool fromCache;
  final DateTime? savedAt;
}

class AppCache {
  AppCache(this._prefs);

  static const String _prefix = 'cache:';

  static const String keyCustomerProfile = 'customer_profile';
  static const String keyStores = 'booking_stores';
  static const String keyBookingTermsAgreed = 'booking_terms_agreed';
  static const String keyBookingLock = 'booking_lock';
  static const String keyBookingJournal = 'booking_journal';

  final SharedPreferences _prefs;

  static Future<AppCache> load() async {
    return AppCache(await SharedPreferences.getInstance());
  }

  Future<void> writeJson(String key, Object? value) async {
    try {
      await _prefs.setString(
        '$_prefix$key',
        jsonEncode(<String, dynamic>{
          'saved_at': DateTime.now().millisecondsSinceEpoch,
          'value': value,
        }),
      );
    } on Object catch (error) {
      debugPrint('AppCache write $key gagal: $error');
    }
  }

  CachedPayload? readJson(String key) {
    final String? raw = _prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final int millis = (decoded['saved_at'] as num?)?.toInt() ?? 0;
      return CachedPayload(
        value: decoded['value'],
        savedAt: DateTime.fromMillisecondsSinceEpoch(millis),
      );
    } on Object catch (error) {
      debugPrint('AppCache read $key gagal: $error');
      return null;
    }
  }

  bool readBool(String key, {bool fallback = false}) {
    final Object? value = readJson(key)?.value;
    return value is bool ? value : fallback;
  }

  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  Future<void> clearAll() async {
    final Iterable<String> keys = _prefs
        .getKeys()
        .where((String k) => k.startsWith(_prefix))
        .toList(growable: false);

    for (final String key in keys) {
      await _prefs.remove(key);
    }
  }
}
