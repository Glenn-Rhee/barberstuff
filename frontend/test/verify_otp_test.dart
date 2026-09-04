import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/verify_otp_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/otp_field.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

typedef _Reply = ({int status, Map<String, dynamic> body});

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.reply, {this.gate});

  final _Reply Function(RequestOptions options) reply;
  final Future<void>? gate;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (gate != null) await gate;
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

final RegisterRequestApi _request = RegisterRequestApi(
  name: 'Damas Test',
  phoneNumber: '081234567890',
  dateOfBirth: DateTime(2000, 5, 15),
  gender: 'male',
  email: 'damassdev@gmail.com',
  password: 'rahasia123',
);

({VerifyOtpProvider provider, _FakeAdapter adapter}) _build(
  _Reply Function(RequestOptions) reply,
) {
  final _FakeAdapter adapter = _FakeAdapter(reply);
  final DioClient client = DioClient();
  client.dio.httpClientAdapter = adapter;

  return (
    provider: VerifyOtpProvider(
      AuthRepository(AuthRemoteDataSource(client.dio)),
      userId: 'user-1',
      registerRequest: _request,
    ),
    adapter: adapter,
  );
}

void _fill(VerifyOtpProvider p, String code) {
  for (int i = 0; i < code.length; i++) {
    p.controllers[i].text = code[i];
  }
}

void main() {
  test('verifikasi berhasil mengirim user_id dan otp', () async {
    final ({VerifyOtpProvider provider, _FakeAdapter adapter}) t = _build(
      (RequestOptions _) => (
        status: 200,
        body: <String, dynamic>{
          'data': <String, dynamic>{},
          'message': 'Berhasil verifikasi akun! Silahkan login.',
          'statusCode': 200,
        },
      ),
    );

    _fill(t.provider, '754173');
    expect(t.provider.isComplete, isTrue);

    expect(await t.provider.submit(), isTrue);
    expect(t.adapter.requests.single.path, '/auth/verify-credential');
    expect(t.adapter.requests.single.data, <String, dynamic>{
      'user_id': 'user-1',
      'otp': '754173',
    });
    expect(t.provider.hasError, isFalse);

    t.provider.dispose();
  });

  test('otp salah menampilkan pesan server dan mengosongkan kotak', () async {
    final ({VerifyOtpProvider provider, _FakeAdapter adapter}) t = _build(
      (RequestOptions _) => (
        status: 400,
        body: <String, dynamic>{
          'data': null,
          'message':
              'OTP tidak valid, silahkan coba lagi. Sisa percobaan 3 kali',
          'statusCode': 400,
        },
      ),
    );

    _fill(t.provider, '000000');
    expect(await t.provider.submit(), isFalse);
    expect(
      t.provider.error?.rawMessage,
      'OTP tidak valid, silahkan coba lagi. Sisa percobaan 3 kali',
    );
    expect(t.provider.hasError, isTrue);
    expect(t.provider.otp, isEmpty);
    expect(t.provider.isComplete, isFalse);

    t.provider.dispose();
  });

  test('kirim ulang memanggil register dan memulai cooldown', () async {
    final ({VerifyOtpProvider provider, _FakeAdapter adapter}) t = _build(
      (RequestOptions _) => (
        status: 200,
        body: <String, dynamic>{
          'data': <String, dynamic>{
            'id': 'user-2',
            'email': 'damassdev@gmail.com',
          },
          'message': 'OTP telah dikirim ke email Anda.',
          'statusCode': 200,
        },
      ),
    );

    expect(t.provider.canResend, isTrue);
    expect(await t.provider.resend(), isTrue);

    expect(t.adapter.requests.single.path, '/auth/register/credential');
    expect(t.provider.userId, 'user-2');
    expect(t.provider.canResend, isFalse);
    expect(t.provider.secondsLeft, VerifyOtpProvider.resendCooldown);

    t.provider.dispose();
  });

  test('sisa percobaan 0 diganti pesan habis, sisanya apa adanya', () async {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('id'));

    for (final int left in <int>[4, 3, 2, 1, 0]) {
      final ({VerifyOtpProvider provider, _FakeAdapter adapter}) t = _build(
        (RequestOptions _) => (
          status: 400,
          body: <String, dynamic>{
            'data': null,
            'message':
                'OTP tidak valid, silahkan coba lagi. Sisa percobaan $left kali',
            'statusCode': 400,
          },
        ),
      );

      _fill(t.provider, '000000');
      expect(await t.provider.submit(), isFalse);

      final bool habis = t.provider.isAttemptExhausted;
      final String shown = habis
          ? l10n.verifyAttemptExhausted
          : t.provider.error!.message(l10n);

      expect(habis, left == 0, reason: 'sisa $left');
      expect(shown, isNot(contains('0 kali')), reason: 'sisa $left');

      t.provider.dispose();
    }
  });

  testWidgets('kirim ulang menampilkan indikator selagi request berjalan', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final Completer<void> gate = Completer<void>();
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions _) => (
        status: 200,
        body: <String, dynamic>{
          'data': <String, dynamic>{
            'id': 'user-2',
            'email': 'damassdev@gmail.com',
          },
          'message': 'OTP telah dikirim ke email Anda.',
          'statusCode': 200,
        },
      ),
      gate: gate.future,
    );

    final DioClient client = DioClient();
    client.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: AuthRepository(AuthRemoteDataSource(client.dio)),
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VerifyOtpPage(
            args: VerifyOtpArgs(userId: 'user-1', registerRequest: _request),
          ),
        ),
      ),
    );

    final AppLocalizations l10n = lookupAppLocalizations(const Locale('id'));

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.ensureVisible(find.text(l10n.verifyResendAction));
    await tester.tap(find.text(l10n.verifyResendAction));
    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
      reason: 'harus ada indikator segera setelah diklik',
    );
    expect(find.text(l10n.verifyResendAction), findsNothing);

    gate.complete();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('3:00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('ketik ulang di kotak terisi tidak menghapus digit lain', (
    WidgetTester tester,
  ) async {
    final List<TextEditingController> controllers =
        List<TextEditingController>.generate(6, (_) => TextEditingController());
    final List<FocusNode> nodes = List<FocusNode>.generate(
      6,
      (_) => FocusNode(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpField(controllers: controllers, focusNodes: nodes),
        ),
      ),
    );

    String code() =>
        controllers.map((TextEditingController c) => c.text).join();

    await tester.enterText(find.byType(TextField).at(0), '754173');
    await tester.pump();
    expect(code(), '754173');

    await tester.enterText(find.byType(TextField).at(0), '79');
    await tester.pump();
    expect(code(), '954173');

    for (final TextEditingController c in controllers) {
      c.dispose();
    }
    for (final FocusNode n in nodes) {
      n.dispose();
    }
  });

  testWidgets('kotak otp maju otomatis dan mundur saat backspace', (
    WidgetTester tester,
  ) async {
    final List<TextEditingController> controllers =
        List<TextEditingController>.generate(6, (_) => TextEditingController());
    final List<FocusNode> nodes = List<FocusNode>.generate(
      6,
      (_) => FocusNode(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpField(controllers: controllers, focusNodes: nodes),
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);

    await tester.enterText(find.byType(TextField).at(0), '9');
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    expect(controllers[0].text, isEmpty);

    await tester.enterText(find.byType(TextField).at(0), '754173');
    await tester.pump();
    expect(
      controllers.map((TextEditingController c) => c.text).join(),
      '754173',
    );

    for (final TextEditingController c in controllers) {
      c.dispose();
    }
    for (final FocusNode n in nodes) {
      n.dispose();
    }
  });
}
