import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _jwt(DateTime expiresAt) {
  String segment(Map<String, dynamic> claims) =>
      base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');

  final String header = segment(<String, dynamic>{'alg': 'HS256'});
  final String payload = segment(<String, dynamic>{
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    'email': 'damassdev@gmail.com',
  });

  return '$header.$payload.tandatangan';
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('masa berlaku dibaca dari klaim exp token, bukan ditebak', () {
    final DateTime expected = DateTime.now().add(const Duration(days: 30));
    final DateTime? actual = AppSession.expiryOf(_jwt(expected));

    expect(actual, isNotNull);
    expect(
      actual!.difference(expected).inSeconds.abs(),
      lessThanOrEqualTo(1),
      reason: 'harus sama dengan exp pada token',
    );
  });

  test('token tanpa struktur jwt jatuh ke masa berlaku cadangan', () async {
    final AppSession session = AppSession();
    await session.saveSession('bukan-jwt');

    expect(AppSession.expiryOf('bukan-jwt'), isNull);
    expect(session.hasValidSession, isTrue);
    expect(
      session.expiresAt!.difference(DateTime.now()).inDays,
      AppSession.fallbackLifetime.inDays - 1,
    );
  });

  test('sesi bertahan setelah aplikasi dibuka ulang', () async {
    final String token = _jwt(DateTime.now().add(const Duration(days: 30)));

    await AppSession().saveSession(token);

    final AppSession restarted = AppSession();
    await restarted.load();

    expect(restarted.hasValidSession, isTrue);
    expect(restarted.accessToken, token);
  });

  test('sesi lewat satu bulan dianggap habis dan dibuang', () async {
    final String expired = _jwt(
      DateTime.now().subtract(const Duration(minutes: 1)),
    );

    final AppSession session = AppSession();
    await session.saveSession(expired);

    expect(session.hasValidSession, isFalse);
    expect(session.accessToken, isNull);

    final AppSession restarted = AppSession();
    await restarted.load();

    expect(restarted.hasValidSession, isFalse);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('access_token'),
      isNull,
      reason: 'token kedaluwarsa harus dihapus dari penyimpanan',
    );
  });

  test('keluar membuang token tapi email yang diingat tetap', () async {
    final AppSession session = AppSession();
    await session.rememberEmail('damassdev@gmail.com');
    await session.saveSession(
      _jwt(DateTime.now().add(const Duration(days: 30))),
    );

    await session.clearSession();

    expect(session.hasValidSession, isFalse);
    expect(session.rememberedEmail, 'damassdev@gmail.com');
  });
}
