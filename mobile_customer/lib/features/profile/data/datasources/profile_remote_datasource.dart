import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_response.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getCustomerProfile() async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.profileCustomer,
    );

    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    final ApiResponse<Map<String, dynamic>> parsed =
        ApiResponse<Map<String, dynamic>>.fromJson(
          body,
          (Map<String, dynamic> json) => json,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      throw ApiException(
        ApiErrorType.server,
        statusCode: res.statusCode,
        rawMessage: parsed.message,
      );
    }

    return parsed.data!;
  }

  Future<void> updateCustomerProfile(Map<String, dynamic> body) async {
    final Response<dynamic> res = await _dio.patch<dynamic>(
      ApiEndpoint.profileCustomer,
      data: body,
    );

    final ApiResponse<Object?> parsed = ApiResponse<Object?>.fromJson(
      res.data as Map<String, dynamic>,
      null,
    );

    final int status = parsed.statusCode != 0
        ? parsed.statusCode
        : res.statusCode ?? 0;

    if (!parsed.isSuccess || status < 200 || status >= 300) {
      throw ApiException(
        ApiErrorType.server,
        statusCode: status,
        rawMessage: parsed.message,
      );
    }
  }
}
