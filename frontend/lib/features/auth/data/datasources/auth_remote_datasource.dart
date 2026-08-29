import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

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
      throw ApiException(
        parsed.message.isNotEmpty ? parsed.message : 'Gagal mendaftar.',
        statusCode: parsed.statusCode,
      );
    }
    return parsed.data!;
  }
}