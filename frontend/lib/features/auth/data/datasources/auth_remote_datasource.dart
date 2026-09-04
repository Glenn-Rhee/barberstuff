import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/auth/data/models/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/oauth_register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_result.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  ApiException _failure(ApiResponse<Object?> res) => ApiException(
    ApiErrorType.server,
    statusCode: res.statusCode,
    rawMessage: res.message,
  );

  Future<RegisterResult> registerCredential(RegisterRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.registerCredential,
      data: request.toJson(),
    );

    final ApiResponse<RegisterResult> parsed =
        ApiResponse<RegisterResult>.fromJson(
          res.data as Map<String, dynamic>,
          RegisterResult.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<VerifyOtpResult> verifyCredential(VerifyOtpRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.verifyCredential,
      data: request.toJson(),
    );

    final ApiResponse<VerifyOtpResult> parsed =
        ApiResponse<VerifyOtpResult>.fromJson(
          res.data as Map<String, dynamic>,
          VerifyOtpResult.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok) {
      throw _failure(parsed);
    }
    return parsed.data ?? const VerifyOtpResult();
  }

  Future<AuthProviderResult> authProvider(String idToken) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.authProvider,
      data: <String, dynamic>{'id_token': idToken, 'provider': 'google'},
    );

    final ApiResponse<AuthProviderResult> parsed =
        ApiResponse<AuthProviderResult>.fromJson(
          res.data as Map<String, dynamic>,
          AuthProviderResult.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<LoginResult> registerOauth(OauthRegisterRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.registerOauth,
      data: request.toJson(),
    );

    final ApiResponse<LoginResult> parsed = ApiResponse<LoginResult>.fromJson(
      res.data as Map<String, dynamic>,
      LoginResult.fromJson,
    );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<LoginResult> loginCredential(LoginRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.loginCredential,
      data: request.toJson(),
    );

    final ApiResponse<LoginResult> parsed = ApiResponse<LoginResult>.fromJson(
      res.data as Map<String, dynamic>,
      LoginResult.fromJson,
    );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }
}
