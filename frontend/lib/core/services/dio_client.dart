import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:mobile_barberstuff/core/config/api_config.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';

class DioClient {
  // configan awal dulu
  DioClient()
  : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      validateStatus: (int? s) => s != null && s < 500,
    ),
  ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final Dio _dio;
  Dio get dio => _dio;


  static ApiException mapError(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException('Koneksi timeout. Periksa jaringan Anda.');
        case DioException.connectionError:
          return const ApiException('Tidak dapat terhubung ke server.');
        default:
          return const ApiException('Terjadi kesalahan pada server.');
      }
    }
    return const ApiException("Terjadi Kesalahan yang tak terduga.");
  }
}