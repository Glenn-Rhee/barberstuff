import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:mobile_barberstuff/core/config/api_config.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';

class DioClient {
  // configan awal dulu
  DioClient({AppSession? session, bool Function()? isOffline})
    : _session = session,
      _isOffline = isOffline,
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          contentType: Headers.jsonContentType,
          validateStatus: (int? s) => s != null && s < 500,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (kDebugMode && (_isOffline?.call() ?? false)) {
            handler.reject(
              DioException.connectionError(
                requestOptions: options,
                reason: 'debug: mode offline',
              ),
              true,
            );
            return;
          }

          final String? token = _session?.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final AppSession? _session;
  final bool Function()? _isOffline;
  final Dio _dio;
  Dio get dio => _dio;

  static ApiException mapError(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException(ApiErrorType.timeout);
        case DioExceptionType.connectionError:
          return const ApiException(ApiErrorType.connection);
        default:
          return const ApiException(ApiErrorType.server);
      }
    }
    return const ApiException(ApiErrorType.unknown);
  }
}
