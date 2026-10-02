import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_response.dart';
import 'package:mobile_barberstuff/core/network/dio_client.dart';

/// Unggah gambar lewat presigned URL object storage:
/// 1. `POST /upload/presign` → `upload_url` dan `object_key`.
/// 2. `PUT` biner gambar langsung ke `upload_url`.
/// 3. `object_key` itulah yang dikirim di field `image_url` / `banner_url`,
///    bukan URL gambarnya.
///
/// URL gambar dari backend adalah presigned GET yang kedaluwarsa dalam
/// 30 menit, jadi hanya untuk ditampilkan. Jangan disimpan lama atau dikirim
/// balik ke server, backend menolak apa pun selain object key.
class ImageUploadService {
  ImageUploadService(this._api, {Dio? storage}) : _storage = storage ?? Dio();

  /// Dio backend yang membawa token. Presign hanya bisa dengan sesi aktif.
  final Dio _api;

  /// Dio polos tanpa token: tanda tangan sudah ada di query `upload_url`,
  /// header Authorization tambahan malah ditolak object storage.
  final Dio _storage;

  static const Map<String, String> _typeByExtension = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
  };

  Future<String> uploadFile(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      return await uploadBytes(bytes, fileName: file.uri.pathSegments.last);
    } on FileSystemException {
      throw const ApiException(ApiErrorType.unknown);
    }
  }

  /// Foto dari URL publik (mis. foto akun Google) diunduh lalu diunggah
  /// ulang, karena backend hanya menerima object key.
  Future<String> uploadFromUrl(String url) async {
    try {
      final Response<List<int>> res = await _storage.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final String type = (res.headers.value(Headers.contentTypeHeader) ?? '')
          .split(';')
          .first
          .trim()
          .toLowerCase();
      final String ext = _extensionOf(type) ?? 'jpg';

      return await uploadBytes(
        Uint8List.fromList(res.data ?? const <int>[]),
        fileName: 'photo.$ext',
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  /// Validasi format dan ukuran (maks 5 MB) diserahkan ke backend supaya
  /// aturannya tidak dobel, pesannya diteruskan lewat [ApiException].
  Future<String> uploadBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final String ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    final String contentType = _typeByExtension[ext] ?? 'image/$ext';

    try {
      final ({String uploadUrl, String objectKey}) target = await _presign(
        fileName: fileName,
        contentType: contentType,
        size: bytes.length,
      );

      // Content-Type wajib sama persis dengan yang ditandatangani saat presign.
      await _storage.put<dynamic>(
        target.uploadUrl,
        data: bytes,
        options: Options(
          contentType: contentType,
          responseType: ResponseType.plain,
        ),
      );

      return target.objectKey;
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<({String uploadUrl, String objectKey})> _presign({
    required String fileName,
    required String contentType,
    required int size,
  }) async {
    final Response<dynamic> res = await _api.post<dynamic>(
      ApiEndpoint.uploadPresign,
      data: <String, dynamic>{
        'file_name': fileName,
        'content_type': contentType,
        'file_size': size,
      },
    );

    final ApiResponse<Map<String, dynamic>> parsed =
        ApiResponse<Map<String, dynamic>>.fromJson(
          res.data as Map<String, dynamic>,
          (Map<String, dynamic> json) => json,
        );

    final String uploadUrl = '${parsed.data?['upload_url'] ?? ''}';
    final String objectKey = '${parsed.data?['object_key'] ?? ''}';

    if (!parsed.isSuccess || uploadUrl.isEmpty || objectKey.isEmpty) {
      throw ApiException(
        ApiErrorType.server,
        statusCode: res.statusCode,
        rawMessage: parsed.message,
      );
    }

    return (uploadUrl: uploadUrl, objectKey: objectKey);
  }

  static String? _extensionOf(String contentType) {
    for (final MapEntry<String, String> e in _typeByExtension.entries) {
      if (e.value == contentType) return e.key;
    }
    return null;
  }
}
