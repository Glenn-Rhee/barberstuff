import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/network/api_response.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';

import '../../app/app_env.dart';

// Bungkus Dio: hasil jadi [ApiResponse], gagal lempar [ApiException]
class ApiClient {
  ApiClient({Dio? dio, String baseUrl = AppEnv.baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              validateStatus: (_) => true,
            ),
          );

  final Dio _dio;
  String? _token;

  // Diperbarui dari header Date tiap respons
  final ServerClock clock = ServerClock();

  // Mengatur token untuk permintaan API
  set token(String? value) {
    _token = value;
    if (value == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $value';
    }
  }

  String? get token => _token;

  // Merequest API
  Future<ApiResponse> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    final Response<dynamic> res;
    try {
      res = await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException('Jaringan Bermasalah', statusCode: 408);
      } else if (e.type == DioExceptionType.badResponse) {
        throw ApiException('Server Bermasalah', statusCode: 500);
      } else if (e.type == DioExceptionType.unknown &&
          e.error is SocketException) {
        throw ApiException('Koneksi Bermasalah', statusCode: 503);
      } else {
        throw ApiException('Maaf Periksa Jaringan Anda', statusCode: 520);
      }
    }
    clock.sync(res.headers.value(HttpHeaders.dateHeader));
    final data = res.data;

    if (data is! Map) {
      throw ApiException(
        'Format Data Tidak Dikenali',
        statusCode: res.statusCode,
      );
    }
    final status = res.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException(
        data['message']?.toString() ?? 'Permintaan Server Gagal',
        statusCode: status,
      );
    }

    return ApiResponse(
      data: data['data'],
      message: data['message']?.toString(),
      meta: data['meta'] as Map<dynamic, dynamic>?,
      status: data['status']?.toString(),
      statusCode: status,
    );
  }

  static Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    return {
      for (final entry in query.entries)
        if (entry.value != null && entry.value != '') entry.key: entry.value,
    };
  }

  Future<ApiResponse> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get(path, queryParameters: _clean(query)));
  Future<ApiResponse> post(String path, {Object? data}) =>
      _send(() => _dio.post(path, data: data));
  Future<ApiResponse> patch(String path, {Object? data}) =>
      _send(() => _dio.patch(path, data: data));
  Future<ApiResponse> delete(String path, {Object? data}) =>
      _send(() => _dio.delete(path, data: data));
}
