import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';

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
}
