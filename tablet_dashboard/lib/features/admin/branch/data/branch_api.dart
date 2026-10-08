import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch_draft.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Kelola cabang (khusus admin): toko, capster, layanan, akun, foto
class BranchApi {
  BranchApi(this._client, {Dio? storage}) : _storage = storage ?? Dio();

  final ApiClient _client;

  // Dio tanpa token untuk PUT ke storage, URL sudah bertanda tangan
  final Dio _storage;

  // Batas limit backend
  static const _apiLimit = 50;
  static const _maxPages = 10;

  static const _imageTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
  };

  // Ambil semua halaman, berhenti saat halaman tidak penuh
  Future<List<Map<String, dynamic>>> _all(
    String path,
    Map<String, Object?> query,
  ) async {
    final items = <Map<String, dynamic>>[];
    for (var page = 1; page <= _maxPages; page++) {
      final res = await _client.get(
        path,
        query: {...query, 'page': page, 'limit': _apiLimit},
      );
      items.addAll(res.list);
      if (res.list.length < _apiLimit) break;
    }
    return items;
  }

  // Toko cabang

  Future<List<Branch>> branches() async => [
    for (final json in await _all('/store/', {'sort_by': 'name'}))
      Branch.fromJson(json),
  ];

  Future<Branch> branch(String id) async =>
      Branch.fromJson((await _client.get('/store/$id')).map);

  // [bannerKey] = object key hasil [uploadImage]
  Future<void> createBranch(BranchDraft draft, {required String bannerKey}) =>
      _client.post(
        '/store/',
        data: {
          'name': draft.name,
          'description': draft.description,
          'address': draft.address,
          'banner_url': bannerKey,
          'open_hour': DateFormatId.clockToApi(draft.openHour),
          'close_hour': DateFormatId.clockToApi(draft.closeHour),
          'lat': draft.latitude,
          'long': draft.longitude,
          'phone_number': draft.phone,
          'store_type': draft.type.api,
          'timezone': draft.timezone.api,
        },
      );

  // Ubah sebagian data, field null tidak dikirim
  Future<void> updateBranch(
    String id, {
    String? name,
    String? phone,
    String? description,
    String? address,
    String? bannerKey,
    String? openHour,
    String? closeHour,
    double? latitude,
    double? longitude,
    BranchType? type,
    bool? open,
  }) => _client.patch(
    '/store/$id',
    data: {
      'name': ?name,
      'phone_number': ?phone,
      'description': ?description,
      'address': ?address,
      'banner_url': ?bannerKey,
      if (openHour != null) 'open_hour': DateFormatId.clockToApi(openHour),
      if (closeHour != null) 'close_hour': DateFormatId.clockToApi(closeHour),
      'lat': ?latitude,
      'long': ?longitude,
      if (type != null) 'store_type': type.api,
      if (open != null) 'status': open ? 'open' : 'close',
    },
  );

  Future<void> deleteBranch(String id) => _client.delete('/store/$id');

  // Capster

  Future<List<Capster>> capsters(String storeId) async => [
    for (final json in await _all('/capster/', {'id_store': storeId}))
      Capster.fromJson(json),
  ];

  Future<void> createCapster({
    required String storeId,
    required String name,
    String? imageKey,
  }) => _client.post(
    '/capster/',
    data: {'id_store': storeId, 'name': name, 'image_url': ?imageKey},
  );

  Future<void> updateCapster(
    String id, {
    String? name,
    bool? active,
    String? imageKey,
  }) => _client.patch(
    '/capster/$id',
    data: {
      'name': ?name,
      if (active != null) 'status': active ? 'active' : 'inactive',
      'image_url': ?imageKey,
    },
  );

  Future<void> deleteCapster(String id) => _client.delete('/capster/$id');

  // Service & paket (tabel yang sama, beda type)

  Future<List<ServiceItem>> services(String storeId, ServiceType type) async =>
      [
        for (final json in await _all('/service/', {
          'id_store': storeId,
          'type': type.api,
        }))
          ServiceItem.fromJson(json),
      ];

  Future<void> createService({
    required String storeId,
    required ServiceType type,
    required String name,
    required int price,
    String? description,
  }) => _client.post(
    '/service/',
    data: {
      'id_store': storeId,
      'type': type.api,
      'name': name,
      'price': price,
      'description': ?description,
    },
  );

  Future<void> updateService(
    String id, {
    String? name,
    int? price,
    String? description,
    bool? active,
  }) => _client.patch(
    '/service/$id',
    data: {
      'name': ?name,
      'price': ?price,
      'description': ?description,
      if (active != null) 'status': active ? 'active' : 'inactive',
    },
  );

  Future<void> deleteService(String id) => _client.delete('/service/$id');

  // Akun cabang (kasir / mitra)

  Future<List<StaffAccount>> accounts(String storeId) async {
    final res = await _client.get('/staff/', query: {'id_store': storeId});
    return [for (final json in res.list) StaffAccount.fromJson(json)];
  }

  // Password awal diisi backend dari password default staff
  Future<void> createAccount({
    required String storeId,
    required String name,
    required String email,
    required StaffRole role,
  }) => _client.post(
    '/staff/',
    data: {
      'id_store': storeId,
      'name': name,
      'email': email,
      'role': role.name,
    },
  );

  // Backend wajib kirim nama dan password baru sekaligus
  Future<void> updateAccount(
    String id, {
    required String name,
    required String password,
  }) => _client.patch('/staff/$id', data: {'name': name, 'password': password});

  Future<void> deleteAccount(String id) => _client.delete('/staff/$id');

  // Upload foto: presign, PUT ke storage, lalu kirim object key-nya
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    final contentType = _imageTypes[ext];
    if (contentType == null) {
      throw const ApiException('Format foto harus JPG, PNG, WEBP, atau GIF');
    }
    final res = await _client.post(
      '/upload/presign',
      data: {
        'file_name': 'photo.$ext',
        'content_type': contentType,
        'file_size': bytes.length,
      },
    );
    final uploadUrl = res.map['upload_url'] as String? ?? '';
    final objectKey = res.map['object_key'] as String? ?? '';
    if (uploadUrl.isEmpty || objectKey.isEmpty) {
      throw const ApiException('Gagal menyiapkan upload foto');
    }
    try {
      // Content-Type wajib sama dengan yang ditandatangani saat presign
      await _storage.put<dynamic>(
        uploadUrl,
        data: bytes,
        options: Options(
          contentType: contentType,
          responseType: ResponseType.plain,
        ),
      );
    } on DioException {
      throw const ApiException('Foto gagal diunggah, coba lagi');
    }
    return objectKey;
  }
}
