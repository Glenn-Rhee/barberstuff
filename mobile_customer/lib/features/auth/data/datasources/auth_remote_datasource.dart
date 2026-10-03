import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_response.dart';
import 'package:mobile_barberstuff/features/auth/data/models/auth_provider_result_model.dart';
import 'package:mobile_barberstuff/features/auth/data/models/forgot_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/forgot_password_result_model.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result_model.dart';
import 'package:mobile_barberstuff/features/auth/data/models/oauth_register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result_model.dart';
import 'package:mobile_barberstuff/features/auth/data/models/reset_password_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_result_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  ApiException _failure(ApiResponse<Object?> res) => ApiException(
    ApiErrorType.server,
    statusCode: res.statusCode,
    rawMessage: res.message,
  );

  Future<RegisterResultModel> registerCredential(
    RegisterRequestApi request,
  ) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.registerCredential,
      data: request.toJson(),
    );

    final ApiResponse<RegisterResultModel> parsed =
        ApiResponse<RegisterResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          RegisterResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<VerifyOtpResultModel> verifyCredential(
    VerifyOtpRequestApi request,
  ) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.verifyCredential,
      data: request.toJson(),
    );

    final ApiResponse<VerifyOtpResultModel> parsed =
        ApiResponse<VerifyOtpResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          VerifyOtpResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok) {
      throw _failure(parsed);
    }
    return parsed.data ?? const VerifyOtpResultModel();
  }

  Future<AuthProviderResultModel> authProvider(String idToken) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.authProvider,
      data: <String, dynamic>{'id_token': idToken, 'provider': 'google'},
    );

    final ApiResponse<AuthProviderResultModel> parsed =
        ApiResponse<AuthProviderResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          AuthProviderResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<LoginResultModel> registerOauth(
    OauthRegisterRequestApi request,
  ) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.registerOauth,
      data: request.toJson(),
    );

    final ApiResponse<LoginResultModel> parsed =
        ApiResponse<LoginResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          LoginResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<LoginResultModel> loginCredential(LoginRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.loginCredential,
      data: request.toJson(),
    );

    final ApiResponse<LoginResultModel> parsed =
        ApiResponse<LoginResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          LoginResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<ForgotPasswordResultModel> forgotPassword(
    ForgotPasswordRequestApi request,
  ) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.forgotPassword,
      data: request.toJson(),
    );

    final ApiResponse<ForgotPasswordResultModel> parsed =
        ApiResponse<ForgotPasswordResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          ForgotPasswordResultModel.fromJson,
        );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok || parsed.data == null) {
      throw _failure(parsed);
    }
    return parsed.data!;
  }

  Future<void> resetPassword(ResetPasswordRequestApi request) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.resetPassword,
      data: request.toJson(),
    );

    final ApiResponse<Object?> parsed = ApiResponse<Object?>.fromJson(
      res.data as Map<String, dynamic>,
      null,
    );

    final bool ok = parsed.statusCode >= 200 && parsed.statusCode < 300;
    if (!ok) {
      throw _failure(parsed);
    }
  }
}
