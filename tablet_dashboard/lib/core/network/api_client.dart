import 'dart:io';

import 'package:dio/dio.dart';

/// Talks to the Barberstuff backend. Every response is wrapped as
/// `{data, message, statusCode, status, meta?}`, so [get]/[post] unwrap `data`
/// and turn a failure into an [ApiException] carrying the server's message.
class ApiClient {
  ApiClient({Dio? dio, String baseUrl = defaultBaseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Content-Type': 'application/json'},
              // Errors carry a readable message in the body, so read it instead of throwing.
              validateStatus: (_) => true,
            ),
          );

  static const defaultBaseUrl = 'https://api.barberstuff.my.id';

  final Dio _dio;

  String? _token;

  /// Set after login; cleared on sign out.
  set token(String? value) {
    _token = value;
    if (value == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $value';
    }
  }

  String? get token => _token;

  Future<ApiResult> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get(path, queryParameters: _clean(query)));

  Future<ApiResult> post(String path, {Object? body}) => _send(() => _dio.post(path, data: body));

  Future<ApiResult> patch(String path, {Object? body}) => _send(() => _dio.patch(path, data: body));

  Future<ApiResult> _send(Future<Response<dynamic>> Function() request) async {
    final Response<dynamic> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw ApiException(_networkMessage(e));
    }

    final body = response.data;
    if (body is! Map) {
      throw ApiException('Respons server tidak dikenali (${response.statusCode})');
    }
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException((body['message'] as String?) ?? 'Permintaan gagal ($status)', statusCode: status);
    }
    return ApiResult(data: body['data'], meta: body['meta'] as Map?, message: body['message'] as String?);
  }

  static Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    return {
      for (final entry in query.entries)
        if (entry.value != null && entry.value != '') entry.key: entry.value,
    };
  }

  /// Keeps the underlying reason visible, so a failure on a real tablet can be
  /// told apart (no network vs DNS vs certificate) instead of guessing.
  static String _networkMessage(DioException e) {
    final cause = e.error;
    final detail = switch (cause) {
      SocketException(osError: final os?) => os.message,
      SocketException() => 'jaringan tidak tersedia',
      HandshakeException() => 'sertifikat/TLS ditolak — cek tanggal & jam perangkat',
      _ => e.message ?? e.type.name,
    };

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Koneksi ke server timeout. Cek jaringan tablet. ($detail)',
      DioExceptionType.connectionError => 'Tidak bisa terhubung ke server: $detail',
      _ => 'Gagal menghubungi server: $detail',
    };
  }
}

class ApiResult {
  const ApiResult({required this.data, this.meta, this.message});

  final Object? data;
  final Map<dynamic, dynamic>? meta;
  final String? message;

  List<Map<String, dynamic>> get list => [
    for (final item in (data as List? ?? const []))
      if (item is Map) item.cast<String, dynamic>(),
  ];

  Map<String, dynamic> get map => (data as Map? ?? const {}).cast<String, dynamic>();

  int get totalData => (meta?['total_data'] as num?)?.toInt() ?? list.length;
  int get totalPages => (meta?['total_pages'] as num?)?.toInt() ?? 1;
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}
