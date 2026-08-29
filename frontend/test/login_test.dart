import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/login_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Reply = ({int status, Map<String, dynamic> body});

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.reply);

  final _Reply Function(RequestOptions options) reply;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final _Reply r = reply(options);
    return ResponseBody.fromString(
      jsonEncode(r.body),
      r.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}

const Map<String, dynamic> _successBody = <String, dynamic>{
  'data': <String, dynamic>{
    'access_token': 'jwt-token',
    'user': <String, dynamic>{
      'user_id': 'c4e8f131',
      'email': 'damassdev@gmail.com',
      'role': 'customer',
    },
  },
  'message': 'Berhasil login.',
  'statusCode': 200,
};

_Reply _ok(RequestOptions _) => (status: 200, body: _successBody);

Future<AppSession> _session([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final AppSession s = AppSession();
  await s.load();
  return s;
}

AuthRepository _repository(_FakeAdapter adapter) {
  final DioClient client = DioClient();
  client.dio.httpClientAdapter = adapter;
  return AuthRepository(AuthRemoteDataSource(client.dio));
}

Future<_FakeAdapter> _pumpLogin(
  WidgetTester tester,
  AppSession session, {
  _Reply Function(RequestOptions) reply = _ok,
}) async {
  final _FakeAdapter adapter = _FakeAdapter(reply);

  await tester.pumpWidget(
    MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AppSession>.value(value: session),
        Provider<AuthRepository>.value(value: _repository(adapter)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: const LoginPage(),
        routes: <String, WidgetBuilder>{
          AppRoute.home: (_) => const Scaffold(body: Text('HOME')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = 'damassdev@gmail.com',
  String password = 'rahasia123',
}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.pump();
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login mengirim email dan password lalu masuk ke beranda', (
    WidgetTester tester,
  ) async {
    final AppSession session = await _session();
    final _FakeAdapter adapter = await _pumpLogin(tester, session);

    await _fillAndSubmit(tester);

    expect(adapter.requests.single.path, '/auth/login/credential');
    expect(adapter.requests.single.data, <String, dynamic>{
      'email': 'damassdev@gmail.com',
      'password': 'rahasia123',
    });
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('tombol masuk tidak mengirim apa pun saat field kosong', (
    WidgetTester tester,
  ) async {
    final AppSession session = await _session();
    final _FakeAdapter adapter = await _pumpLogin(tester, session);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('login gagal menampilkan pesan dari server', (
    WidgetTester tester,
  ) async {
    final AppSession session = await _session();
    await _pumpLogin(
      tester,
      session,
      reply: (RequestOptions _) => (
        status: 400,
        body: <String, dynamic>{
          'data': null,
          'message': 'Email tidak terdaftar.',
          'statusCode': 400,
        },
      ),
    );

    await _fillAndSubmit(tester, email: 'nobody@gmail.com');

    expect(find.text('Email tidak terdaftar.'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Email tidak terdaftar.'), findsNothing);
  });

  testWidgets('ingat saya menyimpan email dan mengisinya lagi', (
    WidgetTester tester,
  ) async {
    final AppSession session = await _session();
    await _pumpLogin(tester, session);

    await tester.tap(find.text('Ingat Saya'));
    await tester.pump();
    await _fillAndSubmit(tester);

    expect(session.rememberedEmail, 'damassdev@gmail.com');

    final LoginProvider next = LoginProvider(
      _repository(_FakeAdapter(_ok)),
      session,
    );
    expect(next.emailController.text, 'damassdev@gmail.com');
    expect(next.rememberMe, isTrue);
    expect(next.isComplete, isFalse);
    next.dispose();
  });

  testWidgets('tanpa ingat saya email tersimpan dihapus', (
    WidgetTester tester,
  ) async {
    final AppSession session = await _session(<String, Object>{
      'flutter.remembered_email': 'lama@gmail.com',
    });
    expect(session.rememberedEmail, 'lama@gmail.com');

    await _pumpLogin(tester, session);
    await tester.tap(find.text('Ingat Saya'));
    await tester.pump();
    await _fillAndSubmit(tester, email: 'baru@gmail.com');

    expect(session.rememberedEmail, isNull);
  });
}
