import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/personal_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Catches every request so the test can assert method, path and body.
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];

  int updateStatus = 200;
  String updateMessage = 'Berhasil mengupdate customer';
  Map<String, dynamic> profile = _profileJson('Danar', '081234567890');

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final bool isUpdate = options.method == 'PATCH';
    final Map<String, dynamic> body = isUpdate
        ? <String, dynamic>{
            'data': 'ok',
            'message': updateMessage,
            'statusCode': updateStatus,
            'status': updateStatus == 200 ? 'success' : 'failed',
          }
        : <String, dynamic>{
            'data': profile,
            'message': 'ok',
            'statusCode': 200,
            'status': 'success',
          };

    return ResponseBody.fromString(
      jsonEncode(body),
      isUpdate ? updateStatus : 200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _profileJson(String name, String phone) =>
    <String, dynamic>{
      'id': 'cust-1',
      'name': name,
      'email': 'danar@barberstuff.id',
      'phone_number': phone,
      'gender': 'male',
      'member_points': 1250,
      'premium_type': 'gold',
    };

Future<AppCache> _cache() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return AppCache.load();
}

({Dio dio, _RecordingAdapter adapter}) _dio() {
  final _RecordingAdapter adapter = _RecordingAdapter();
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.test',
      validateStatus: (int? s) => s != null && s < 500,
    ),
  )..httpClientAdapter = adapter;
  return (dio: dio, adapter: adapter);
}

void main() {
  test('update dikirim sebagai PATCH ke /profile/customer', () async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      await _cache(),
    );

    await repository.updateCustomerProfile(name: 'Danar Baru');

    final RequestOptions update = client.adapter.requests.first;
    expect(update.method, 'PATCH');
    expect(update.path, '/profile/customer');
    expect(update.data, <String, dynamic>{'name': 'Danar Baru'});
  });

  test('foto dikirim dengan nama field image_url', () async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      await _cache(),
    );

    await repository.updateCustomerProfile(imageUrl: 'https://cdn.test/a.png');

    expect(client.adapter.requests.first.data, <String, dynamic>{
      'image_url': 'https://cdn.test/a.png',
    });
  });

  test('profil lama di cache dibuang, lalu diambil ulang', () async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    final AppCache cache = await _cache();
    await cache.writeJson(
      AppCache.keyCustomerProfile,
      _profileJson('Nama Lama', '081234567890'),
    );

    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      cache,
    );
    client.adapter.profile = _profileJson('Nama Baru', '081234567890');

    final CustomerProfile updated = await repository.updateCustomerProfile(
      name: 'Nama Baru',
    );

    expect(updated.name, 'Nama Baru');
    expect(
      client.adapter.requests.map((RequestOptions r) => r.method),
      <String>['PATCH', 'GET'],
    );
    expect(
      CustomerProfile.fromJson(
        cache.readJson(AppCache.keyCustomerProfile)!.asMap!,
      ).name,
      'Nama Baru',
    );
  });

  test('pesan gagal dari server diteruskan sebagai ApiException', () async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    client.adapter
      ..updateStatus = 400
      ..updateMessage = 'Data tidak valid atau gagal mengupdate customer';

    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      await _cache(),
    );

    await expectLater(
      repository.updateCustomerProfile(name: 'x'),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.rawMessage,
          'rawMessage',
          'Data tidak valid atau gagal mengupdate customer',
        ),
      ),
    );
  });

  // validate() membaca formKey.currentState, jadi Form-nya harus benar-benar
  // ter-render sebelum save() dipanggil.
  Future<void> mountForm(WidgetTester tester, PersonalInfoProvider provider) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: provider.formKey,
            child: TextFormField(controller: provider.nameController),
          ),
        ),
      ),
    );
  }

  testWidgets('provider hanya mengirim field yang berubah', (
    WidgetTester tester,
  ) async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      await _cache(),
    );
    final CustomerProfile profile = CustomerProfile.fromJson(
      _profileJson('Danar', '081234567890'),
    );

    final PersonalInfoProvider provider = PersonalInfoProvider(
      profile,
      repository,
    );
    await mountForm(tester, provider);

    provider.nameController.text = 'Danar Edit';
    client.adapter.profile = _profileJson('Danar Edit', '081234567890');

    final CustomerProfile? updated = await provider.save();

    expect(updated?.name, 'Danar Edit');
    expect(client.adapter.requests.first.data, <String, dynamic>{
      'name': 'Danar Edit',
    });
    expect(provider.isSaving, isFalse);
    expect(provider.error, isNull);
  });

  testWidgets('tanpa perubahan tidak ada permintaan ke server', (
    WidgetTester tester,
  ) async {
    final ({Dio dio, _RecordingAdapter adapter}) client = _dio();
    final ProfileRepository repository = ProfileRepository(
      ProfileRemoteDataSource(client.dio),
      await _cache(),
    );
    final CustomerProfile profile = CustomerProfile.fromJson(
      _profileJson('Danar', '081234567890'),
    );

    final PersonalInfoProvider provider = PersonalInfoProvider(
      profile,
      repository,
    );
    await mountForm(tester, provider);

    expect(await provider.save(), isNotNull);
    expect(client.adapter.requests, isEmpty);
  });
}
