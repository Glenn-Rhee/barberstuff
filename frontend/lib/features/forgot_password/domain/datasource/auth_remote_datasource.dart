import 'package:dio/dio.dart';
import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/forgot_password_request_api.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/reset_password_request_api.dart';

Future<ForgotPasswordResult> forgotPassword(
  ForgotPasswordRequestApi request,
) async {
  final Response<dynamic> res = await _dio.post<dynamic>(
    ApiEndpoint.forgotPassword,
    data: request.toJson(),
  );

  final ApiResponse<ForgotPasswordResult> parsed =
      ApiResponse<ForgotPasswordResult>.fromJson(
        res.data as Map<String, dynamic>,
        ForgotPasswordResult.fromJson,
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
  if (!ok) throw _failure(parsed);
}
